"""Mirror of prebuild diffutils release info

See https://github.com/kormide/diffutils-prebuilt
"""

# The integrity hashes can be computed with
# sha256sum -b [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "3.12": {
        "cmp": {
            "darwin_amd64": "39783e3d0990480ce8c3e44d4c4b59907682e9f3f54ebbe128c84614e5a97300",
            "darwin_arm64": "625c52d68d0685c9e503e519005663f4d55ee9ad0ccbbe7b84660c00a494a95d",
            "linux_amd64": "a9758cc4647738ffde132df194bc29e2a99cf8b62b80c01ae267a9eb17dc330b",
            "linux_arm64": "b3ffc6089cf0663e49ca38e09eb83d5f57bec444607950985ce449fc9003fe41",
            "windows_amd64": "aa933f29c6af65a5dfd975ce8080252f07a4b326c1106635943c99b058ead26c",
        },
        "diff": {
            "darwin_amd64": "804f64394092d62765e4014f298dde59a4476ee0681ca1505f94c376fef804e0",
            "darwin_arm64": "2656be049ce9c90835d02acbdc47f0ed54b9665f639dce1376c3c2adb6c2692d",
            "linux_amd64": "aba3a7c4f2ad3c7c26fe26c76e6b27762e3827cc28c2aff226d32c2032b5cfa2",
            "linux_arm64": "c02fa89e7cb3e761806f94774fd520c1d37594af718fe45b31c14d2698039aae",
            "windows_amd64": "5eb674b470fed4af007dc2b039e331bc959b3201041809eaee828deaf37d895e",
        },
        "diff3": {
            "darwin_amd64": "59a34cff2f9a3a52222e2b398b79f3bf59aff1244fe439c8e4d457061a9b22b3",
            "darwin_arm64": "ca602d9c1083f486bb28f2390b647e1d442d6cfcf8c33250a8310e881e833468",
            "linux_amd64": "40cd281dce369f7996d255f73f21d919830820618bc61c399eae4aa2f0fc0e6d",
            "linux_arm64": "52c4b10e09407fe9399a4665739659c01373cd60baf3f635970739679533bd64",
            "windows_amd64": "66fe09a11e7f3e50dfbd8c8bfcc443329655ea04925122b49f4dfe207f057d91",
        },
        "sdiff": {
            "darwin_amd64": "13700b905ecc7df60a4674b3262acedac21c037af2060701b2af2cf0620aa2e6",
            "darwin_arm64": "1390afec1f44bc54c29358eb62a1f642d7ee199aebe17884b5cd12e186684ddd",
            "linux_amd64": "aa8dc3c6dba066a9858f6be322cab80d97f52bade86e3ce5de8d5c9d349a88fb",
            "linux_arm64": "ac12605d018bda2d44f6c03efcb3573a67fb0575455e7e42749bb35db0141daf",
            "windows_amd64": "cae2c709b91846bc88bdbab237b9f34a3dcf8cb82c12c26d6f70ad95e7a7011d",
        },
    },
}

LATEST_VERSION = TOOL_VERSIONS.keys()[-1]
