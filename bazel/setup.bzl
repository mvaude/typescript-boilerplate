load("@build_bazel_rules_nodejs//:index.bzl", "nodejs_binary")
load("@npm//@bazel/typescript:index.bzl", "ts_project")
load("@npm//@bazel/typescript:index.bzl", "ts_config")
load("//bazel:test.bzl", "jest_test")
load("//bazel:lint.bzl", "eslint_test")

def ts_setup(name, srcs, sample_path = ''):
  ts_config(
    name = "tsconfig.jest.json",
    src = "//:tsconfig.test.json",
    deps = [
        "//:tsconfig.json",
    ],
  )
  srcs_tests = [src.replace('.ts', '.test.ts') for src in srcs]
  srcs_samples = [src.replace('.ts', '.json') for src in srcs] if len(sample_path) > 0 else []
  srcs_deps = ['//' + sample_path + ':' + src for src in srcs_samples] if len(sample_path) > 0 else []
  ts_project(
      name = "lib",
      # glob is a quick way to select all the code,
      # but has performance penalty in that Bazel must evaluate it.
      srcs = srcs,
      resolve_json_module = True,
      declaration = True,
      incremental = True,
      source_map = False,
      tsconfig = "//:tsconfig.json",
      deps = [
        '@npm//@types/node',
        '@npm//@types/jest'
      ],
  )

  nodejs_binary(
      name = name,
      data = [
          ":lib",
      ],
      entry_point = ":main.ts",
  )

  ts_project(
    name = "lib_test",
    srcs = srcs_tests + srcs_deps,
    resolve_json_module = True,
    declaration = True,
    incremental = True,
    source_map = False,
    tsconfig = "//:tsconfig.json",
    deps = [
      '@npm//@types/node',
      '@npm//@types/jest',
      ':lib'
    ],
  )

  jest_test(
    name = "test",
    srcs = [
      ':lib_test',
    ],
    jest_config = "//:jest.config.js",
    tags = [
      # TODO: why does this fail almost all the time, but pass on local Mac?
      "no-bazelci-mac",
      # Need to set the pwd to avoid jest needing a runfiles helper
      # Windows users with permissions can use --enable_runfiles
      # to make this test work
      "no-bazelci-windows"
    ],
    deps = [
      '@npm//@types/jest',
      '@npm//ts-jest',
      '@npm//jest',
      '@npm//typescript',
      ':lib',
    ],
    timeout = "short"
  )

  eslint_test(
      name = "lint",
      srcs = srcs + srcs_tests + srcs_deps,
      configs = [
          "//:.eslintrc.yml",
          "//:.eslintignore",
          "//:.prettierrc.yml",
          "//:tsconfig.json",
          "//:tsconfig.test.json",
      ],
      deps = [
          '@npm//@types/node',
          '@npm//@types/jest',
          '@npm//@typescript-eslint/eslint-plugin',
          '@npm//@typescript-eslint/parser',
          '@npm//eslint',
          '@npm//eslint-config-prettier',
          '@npm//eslint-formatter-pretty',
          '@npm//eslint-import-resolver-typescript',
          '@npm//eslint-plugin-eslint-comments',
          '@npm//eslint-plugin-import',
          '@npm//eslint-plugin-jsdoc',
          '@npm//eslint-plugin-prettier',
          '@npm//eslint-plugin-promise',
      ],
      timeout = "short"
  )
