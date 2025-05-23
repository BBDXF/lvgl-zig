# lvgl-zig
Use zig to build lvgl project.
support windows and linux.

## install
```bash
git submodule add https://github.com/lvgl/lvgl.git
git add .gitmodules lvgl

```

## build
```bash
git clone --recurse-submodules  https://github.com/bbdxf/lvgl-zig.git
git submodule init
git submodule update

zig build
```

## use it
please refer to the `build.zig` file to integrate it into your project.

```bash
zig build
./zig-out/bin/demo ./zig-out/bin/demo.js 
```

