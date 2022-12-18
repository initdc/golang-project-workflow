# frozen_string_literal: true

SUB_CMD = %w[test less help].freeze
EMPTY = ["", " ", "  "].freeze
NOT_VALID = ["not-valid"].freeze

def get_version(source = ARGV, index = 0, default_version)
    if not source.empty?
        filtered = source.select { |e| not e.to_s.start_with? "-" }
        if filtered.empty?
            puts "version fallback to: #{default_version}"
            return default_version
        elsif filtered[index].nil?
            puts "version not exists"
            puts "version fallback to: #{default_version}"
            return default_version
        elsif SUB_CMD.include? filtered[index]
            puts "subcommand detected"
            return get_version source, index + 1, default_version
        elsif EMPTY.include? filtered[index]
            print "version is empty: "
            p filtered[index]
            puts "version fallback to: #{default_version}"
            return default_version
        elsif NOT_VALID.include? filtered[index]
            print "version not valid: "
            p filtered[index]
            puts "version fallback to: #{default_version}"
            return default_version
        else
            version = filtered[index]
            index_source = source.index version
            puts "version = #{version}, get from #{source}[#{index_source}]"
            return version
        end
    else
        puts "source is empty"
        puts "version = #{default_version}, by default"
        return default_version
    end
end
