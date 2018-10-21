project('com.github.philip-scott.canvas-demo', ['vala', 'c'],
    version: '0.2.0'
)

gnome = import('gnome')
i18n = import('i18n')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')


c_args = [
  '-include', 'config.h',
]

executable(
    'com.github.philip-scott.canvas-demo',
    'src/Application.vala',
    'src/Window.vala',
    'src/ResponsiveCanvas.vala',
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('libsoup-2.4'),
        dependency('libsecret-1'),
        dependency('goocanvas-2.0'),
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')
