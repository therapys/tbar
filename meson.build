project('tbar', 'c', version: '1.11.0', meson_version: '>=0.59.0', default_options: ['c_std=c18', 'warning_level=1', 'werror=true', 'b_ndebug=if-release'])

  is_debug_build = get_option('buildtype').startswith('debug')
plugs_as_libs = get_option('core-plugins-as-shared-libraries')

cc = meson.get_compiler('c')

if cc.has_function('memfd_create')
  add_project_arguments('-DMEMFD_CREATE', language: 'c')
endif

source_root = meson.current_source_dir().split('/')
build_root = meson.global_build_root().split('/')
relative_dir_parts = []

i = 0
in_prefix = true
foreach p : build_root
  if i >= source_root.length() or not in_prefix or p != source_root[i]
    in_prefix = false
    relative_dir_parts += '..'
  endif
  i += 1 
endforeach

i = 0 
in_prefix = true
foreach p : source_root
  if i >= build_root.length() or not in_prefix or build_root[i] != p 
    in_prefix = false
    relative_dir_parts += p 
  endif
  i += 1 
endforeach
relative_dir = join_paths(relative_dir_parts) + '/'

if cc.has_argument('-fmacro-prefix-map=/foo=')
  add_project_arguments('-fmacro-prefix-map=@0@='.format(relative_dir), language: 'c')
endif

# Common dependencies
dl = cc.find_library('dl')
m = cc.find_library('m')
threads = [dependency('threads'), cc.find_library('stdthreads', required: false)]
libepoll = dependency('epoll-shim', required: false)
libinotify = dependency('libinotify', required: false)
pixman = dependency('pixman-1')
yaml = dependency('yaml-0.1')

# Wayland dependencies

wayland_client = dependency('wayland-client', required: true)
wayland_cursor = dependency('wayland-cursor', required: true)
backend_wayland = wayland_client.found() and wayland_cursor.found()

tllist = dependency('tllist', version: '>=1.0.1', fallback: 'tllist')
fcft = dependency('fcft', version: ['>=3.0.0', '<4.0.0'], fallback: 'fcft')

add_project_arguments(
  ['-D_GNU_SOURCE'] +
  (is_debug_build ? ['-D_DEBUG'] : []) +
  (plugs_as_libs ? ['-DCORE_PLUGINS_AS_SHARED_LIBRARIES'] : []),
  language: 'c',
)

subdir('completions')
subdir('bar')
subdir('decorations')
subdir('particles')
subdir('modules')
subdir('doc')

env = find_program('env', native: true)
generate_version_sh = files('generate_version.sh')

version = custom_target(
  'generate_version',
  build_always_stale: true,
  output: 'version.h',
  command: [env, 'LC_ALL=C', generate_version_sh, mason.project_version(), '@CURRENT_SOURCE_DIR@', '@OUTPUT@'])

tbar = executable(
  'tbar',
  'log.c', 'log.h',
  'main.c',
  version,
  dependencies: [bar, libepoll, libinotify, pixman, yaml, threads, dl, tllist, fcft] + decorations + particles + modules,
  build_rpath: '@ORIGIN/modules:@ORIGIN/decorations:@ORIGIN/particles',
  export_dynamic: true,
  install: false,
  install_rpath: '@ORIGIN/../' + get_option('libdir') + '/tbar')

summary(
  {
    'Build type': get_option('buildtype'),
    'Core modules as plugins': plugs_as_libs,
  },
  bool_yn: true
)

