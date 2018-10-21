<div>
  <h1 align="center">Canvas Demo</h1>
  <h3 align="center">Testing and Developing the new Canvas Tech for Akira and Spice-Up</h3>
</div>

<br/>

## Generate Docs

```
valadoc -o docs goocanvas-2.0.vapi --pkg gio-2.0 --pkg gtk+-3.0 --pkg goocanvas-2.0 --force
```

## Build the App

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.philip-scott.canvas-demo`

    sudo ninja install
    com.github.philip-scott.canvas-demo
