# frozen_string_literal: true

require "./version"
require "./get-version"
require "./get-go-targets"

PROGRAM = "demo"
# VERSION = "v0.0.1"
BUILD_CMD = "go build -o"
# used in this way:
# ENV BUILD_CMD OUTPUT_PATH
TEST_CMD = "go test"

TARGET_DIR = "target"
UPLOAD_DIR = "upload"

def clean
    `rm -rf #{TARGET_DIR} #{UPLOAD_DIR}`
end

# go tool dist list
OS_ARCH = %w[
    aix/ppc64
    android/386
    android/amd64
    android/arm
    android/arm64
    darwin/amd64
    darwin/arm64
    dragonfly/amd64
    freebsd/386
    freebsd/amd64
    freebsd/arm
    freebsd/arm64
    illumos/amd64
    ios/amd64
    ios/arm64
    js/wasm
    linux/386
    linux/amd64
    linux/arm
    linux/arm64
    linux/mips
    linux/mips64
    linux/mips64le
    linux/mipsle
    linux/ppc64
    linux/ppc64le
    linux/riscv64
    linux/s390x
    netbsd/386
    netbsd/amd64
    netbsd/arm
    netbsd/arm64
    openbsd/386
    openbsd/amd64
    openbsd/arm
    openbsd/arm64
    openbsd/mips64
    plan9/386
    plan9/amd64
    plan9/arm
    solaris/amd64
    windows/386
    windows/amd64
    windows/arm
    windows/arm64
].freeze

ARM = %w[5 6 7].freeze

TEST_OS_ARCH = %w[
    darwin/amd64
    darwin/arm64
    linux/386
    linux/amd64
    linux/arm
    linux/arm64
    linux/riscv64
    windows/386
    windows/amd64
    windows/arm64
].freeze

LESS_OS_ARCH = %w[linux/amd64 linux/arm64].freeze

QEMU_BINFMT = ["qemu-user"].freeze

ARCH_EXEC = {
    '386': "",
    'amd64': "",
    'arm': "qemu-arm",
    'arm64': "qemu-aarch64",
    'mips': "qemu-mips",
    'mips64': "qemu-mips64",
    'mips64le': "qemu-mips64el",
    'mipsle': "qemu-mipsel",
    'ppc64': "qemu-ppc64",
    'ppc64le': "qemu-ppc64le",
    'riscv64': "qemu-riscv64",
    's390x': "qemu-s390x"
}.freeze

def run_install
    cmd = "sudo apt-get install -y #{QEMU_BINFMT.join(" ")}"
    puts cmd
    IO.popen(cmd) { |r| puts r.readlines }
end

version = get_version ARGV, 0, VERSION

test_bin = (ARGV[0] == "test") || false
less_bin = (ARGV[0] == "less") || false

run_test = (ARGV.include? "--run-test") || false
catch_error = (ARGV.include? "--catch-error") || false
install_qemu = (ARGV.include? "--install-qemu") || false

if install_qemu
    run_install
    return
end

os_arch = get_go_targets || OS_ARCH
os_arch = TEST_OS_ARCH if test_bin
os_arch = LESS_OS_ARCH if less_bin

# on local machine, you may re-run this script
clean if test_bin || less_bin
`mkdir -p #{TARGET_DIR} #{UPLOAD_DIR}`

os_arch.each do |target_platform|
    tp_array = target_platform.split("/")
    os = tp_array[0]
    architecture = tp_array[1]

    windows = os == "windows"

    program_bin = !windows ? PROGRAM : "#{PROGRAM}.exe"

    if architecture == "arm"
        ARM.each do |variant|
            puts "GOOS=#{os} GOARCH=#{architecture} GOARM=#{variant}"

            if run_test and os == "linux"
                qemu_runner = ARCH_EXEC[:"#{architecture}"]
                exec_arg = qemu_runner != "" ? "--exec #{qemu_runner}" : ""

                test_cmd =
                    "GOOS=#{os} GOARCH=#{architecture} GOARM=#{variant} #{TEST_CMD} #{exec_arg}"
                puts test_cmd
                test_result = system test_cmd
                exit 1 if catch_error and !test_result
            elsif run_test
                puts "skip testing for #{os}/#{architecture}/v#{variant}"
            end

            upload_bin =
                if !windows
                    "#{PROGRAM}-#{version}-#{os}-#{architecture}-#{variant}"
                else
                    "#{PROGRAM}-#{version}-#{os}-#{architecture}-#{variant}.exe"
                end

            dir = "#{TARGET_DIR}/#{os}/#{architecture}/v#{variant}"
            `GOOS=#{os} GOARCH=#{architecture} GOARM=#{variant} #{BUILD_CMD} #{dir}/#{program_bin}`
            `ln #{dir}/#{program_bin} #{UPLOAD_DIR}/#{upload_bin}`
        end
    else
        puts "GOOS=#{os} GOARCH=#{architecture}"

        if run_test and os == "linux"
            qemu_runner = ARCH_EXEC[:"#{architecture}"]
            exec_arg = qemu_runner != "" ? "--exec #{qemu_runner}" : ""

            test_cmd =
                "GOOS=#{os} GOARCH=#{architecture} #{TEST_CMD} #{exec_arg}"
            puts test_cmd
            test_result = system test_cmd
            exit 1 if catch_error and !test_result
        elsif run_test
            puts "skip testing for #{os}/#{architecture}"
        end

        upload_bin = if !windows
                         "#{PROGRAM}-#{version}-#{os}-#{architecture}"
                     else
                         "#{PROGRAM}-#{version}-#{os}-#{architecture}.exe"
                     end

        `GOOS=#{os} GOARCH=#{architecture} #{BUILD_CMD} #{TARGET_DIR}/#{os}/#{architecture}/#{program_bin}`
        `ln #{TARGET_DIR}/#{os}/#{architecture}/#{program_bin} #{UPLOAD_DIR}/#{upload_bin}`
    end
end

# cmd = "file #{UPLOAD_DIR}/**"
# IO.popen(cmd) do |r|
#     puts r.readlines
# end

file = "#{UPLOAD_DIR}/BINARYS"
IO.write(file, "")

cmd = "tree #{TARGET_DIR}"
IO.popen(cmd) do |r|
    rd = r.readlines
    puts rd

    rd.each { |o| IO.write(file, o, mode: "a") }
end

Dir.chdir UPLOAD_DIR do
    file = "SHA256SUM"
    IO.write(file, "")

    cmd = "sha256sum *"
    IO.popen(cmd) do |r|
        rd = r.readlines

        rd.each do |o|
            if !o.include? "SHA256SUM" and !o.include? "BINARYS"
                print o
                IO.write(file, o, mode: "a")
            end
        end
    end
end

# `docker buildx build --platform linux/amd64 -t demo:amd64 . --load`
# cmd = "docker run demo:amd64"
# IO.popen(cmd) do |r|
#     puts r.readlines
# end
