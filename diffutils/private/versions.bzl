"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# sha256sum -b [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "0.5.0": {
        "aarch64-apple-darwin": "0c164e83d59fbbc23b93003d446ff7de228b8f81c64f08b1ef1f5ad1cee1b347",
        "aarch64-unknown-linux-gnu": "d6249274d4e1569b37c6b1d7f68418824d99cacde31a55c72ddd65d3f8fd355c",
        "x86_64-apple-darwin": "fc11327f89f624a254b9c1828aedc5c35c472450915280497c8f627f3561f370",
        "x86_64-pc-windows-msvc": "36c900a06060ee31621fcdecb9bf223b40dd23d45e91ba98101b5d3aa5c70d18",
        "x86_64-unknown-linux-gnu": "322e59ab837ecaf838c4511091615b01bf289030699133e45fa5843e53dfc32b",
    },
}

LATEST_VERSION = TOOL_VERSIONS.keys()[-1]
