TARGET_DIR = "target"
UPLOAD_DIR = "upload"

PROGRAM = "demo"
VERSION = "v0.0.1"
BUILD_CMD = "go build -o"
# used in this way:
# ENV BUILD_CMD OUTPUT_PATH

# go tool dist list
OS_ARCH = [
    "aix/ppc64",
    "android/386",
    "android/amd64",
    "android/arm",
    "android/arm64",
    "darwin/amd64",
    "darwin/arm64",
    "dragonfly/amd64",
    "freebsd/386",
    "freebsd/amd64",
    "freebsd/arm",
    "freebsd/arm64",
    "illumos/amd64",
    "ios/amd64",
    "ios/arm64",
    "js/wasm",
    "linux/386",
    "linux/amd64",
    "linux/arm",
    "linux/arm64",
    "linux/mips",
    "linux/mips64",
    "linux/mips64le",
    "linux/mipsle",
    "linux/ppc64",
    "linux/ppc64le",
    "linux/riscv64",
    "linux/s390x",
    "netbsd/386",
    "netbsd/amd64",
    "netbsd/arm",
    "netbsd/arm64",
    "openbsd/386",
    "openbsd/amd64",
    "openbsd/arm",
    "openbsd/arm64",
    "openbsd/mips64",
    "plan9/386",
    "plan9/amd64",
    "plan9/arm",
    "solaris/amd64",
    "windows/386",
    "windows/amd64",
    "windows/arm",
    "windows/arm64"
]

ARM = ["5", "6", "7"]

`mkdir -p #{TARGET_DIR} #{UPLOAD_DIR}`

for target_platform in OS_ARCH do
    tp_array = target_platform.split('/')
    os = tp_array[0]
    architecture = tp_array[1]

    if architecture == "arm" 
        for variant in ARM do
            puts "GOOS=#{os} GOARCH=#{architecture} GOARM=#{variant}"
            `GOOS=#{os} GOARCH=#{architecture} GOARM=#{variant} #{BUILD_CMD} #{TARGET_DIR}/#{os}/#{architecture}/v#{variant}/#{PROGRAM}`
            `ln #{TARGET_DIR}/#{os}/#{architecture}/v#{variant}/#{PROGRAM} #{UPLOAD_DIR}/#{PROGRAM}-#{VERSION}-#{os}-#{architecture}-#{variant}`
        end
    else
        puts "GOOS=#{os} GOARCH=#{architecture}"
        `GOOS=#{os} GOARCH=#{architecture} #{BUILD_CMD} #{TARGET_DIR}/#{os}/#{architecture}/#{PROGRAM}`
        `ln #{TARGET_DIR}/#{os}/#{architecture}/#{PROGRAM} #{UPLOAD_DIR}/#{PROGRAM}-#{VERSION}-#{os}-#{architecture}`
    end
end

cmd = "file #{UPLOAD_DIR}/**"
IO.popen(cmd) do |r|
    puts r.readlines
end

`docker buildx build --platform linux/amd64 -t demo:amd64 . --load`
cmd = "docker run demo:amd64"
IO.popen(cmd) do |r|
    puts r.readlines
end