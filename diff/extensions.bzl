"""Extensions for bzlmod.

Installs a diffutils toolchain based on prebuilt GNU diffutils binaries from https://github.com/kormide/diffutils-prebuilt.
Every module can define a toolchain version under the default name, "diffutils".
The latest of those versions will be selected (the rest discarded),
and will always be registered by diff.bzl.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load("//diff/private:versions.bzl", "LATEST_VERSION")
load(":repositories.bzl", "diffutils_register_toolchains")

_DEFAULT_NAME = "diffutils"
DEFAULT_DIFFUTILS_VERSION = LATEST_VERSION

_diffutils_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one diff toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = _DEFAULT_NAME),
    "diffutils_version": attr.string(doc = "Explicit version of GNU prebuilt diffutils binaries.", default = DEFAULT_DIFFUTILS_VERSION),
})

def _toolchain_extension(mctx):
    registrations = {}
    for mod in mctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the diffutils toolchain.
                This prevents conflicting registrations in the global namespace of external repos.
                """)
            if toolchain.name not in registrations.keys():
                registrations[toolchain.name] = []
            registrations[toolchain.name].append(toolchain.diffutils_version)

    for name, versions in registrations.items():
        if len(versions) > 1:
            # It's unclear whether diffutils uses a semantic version strategy, so just
            # assume backwards compatibility and use the newest version found in the
            # dependency graph.
            selected = sorted(versions, reverse = True)[0]

            # buildifier: disable=print
            print("NOTE: diffutils toolchain {} has multiple versions {}, selected {}".format(name, versions, selected))
        else:
            selected = versions[0]

        diffutils_register_toolchains(
            name = name,
            diffutils_version = selected,
            register = False,
        )

    return mctx.extension_metadata(
        reproducible = True,
    )

diffutils = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": _diffutils_toolchain},
    os_dependent = False,
    arch_dependent = False,
    doc = "Module extension for installing a diffutils toolchain.",
)
