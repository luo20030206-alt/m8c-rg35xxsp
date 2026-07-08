#!/bin/bash

set -e

cd /build

# Create output directory
mkdir -p /build/compiled/wiliwili

# Clone wiliwili source
echo "Cloning wiliwili..."
git clone --recursive https://github.com/xfangfang/wiliwili.git

# Build wiliwili
echo "Building wiliwili..."
cd /build/wiliwili
mkdir -p build && cd build
cmake .. -DPLATFORM_DESKTOP=ON -DCMAKE_BUILD_TYPE=Release -DENABLE_MPV=OFF
make -j$(nproc)

if [ $? -ne 0 ]; then
  echo "wiliwili build failed"
  exit 1
fi

# Copy executable
if [ -f "/build/wiliwili/build/wiliwili" ]; then
  cp -v /build/wiliwili/build/wiliwili /build/compiled/wiliwili
  echo "Copied wiliwili executable"
else
  echo "Error: wiliwili executable not found"
  exit 1
fi

# Create a simple launcher script
cat <<'EOF' >/build/compiled/wiliwili.sh
#!/bin/sh
cd $(dirname $0)
./wiliwili
EOF
chmod +x /build/compiled/wiliwili.sh

# Check build output
check_build_output() {
    if [ -f "/build/compiled/wiliwili/wiliwili" ]; then
        file_type=$(file /build/compiled/wiliwili/wiliwili)
        if [[ $file_type == *"ARM aarch64"* && $file_type == *"LSB"* && $file_type == *"executable"* ]]; then
            echo "✓ wiliwili executable present and valid ($(basename "$file_type"))"
        else
            echo "✗ wiliwili executable present but may be invalid: $file_type"
            exit 1
        fi
    else
        echo "✗ wiliwili executable missing"
        exit 1
    fi
    echo "Build completed successfully."
}

check_build_output
echo "All compiled files are in /build/compiled/wiliwili"
