<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Extensions for bzlmod

<a id="diffutils"></a>

## diffutils

<pre>
diffutils = use_extension("@diff.bzl//diff:extensions.bzl", "diffutils")
diffutils.toolchain(<a href="#diffutils.toolchain-name">name</a>, <a href="#diffutils.toolchain-diffutils_version">diffutils_version</a>)
</pre>

Module extension for installing a diffutils toolchain based on prebuilt GNU diffutils
binaries from https://github.com/kormide/diffutils-prebuilt.

Every module can define a toolchain version under the default name, "diffutils".
The latest of those versions will be selected (the rest discarded),
and will always be registered by diff.bzl.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.


**TAG CLASSES**

<a id="diffutils.toolchain"></a>

### toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="diffutils.toolchain-name"></a>name |  Base name for generated repositories, allowing more than one diffutils toolchain to be registered. Overriding the default is only permitted in the root module.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `"diffutils"`  |
| <a id="diffutils.toolchain-diffutils_version"></a>diffutils_version |  Explicit version of GNU prebuilt diffutils binaries.   | String | optional |  `"3.12"`  |


