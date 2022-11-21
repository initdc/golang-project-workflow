def get_go_targets
    cmd = "go tool dist list"
    IO.popen(cmd) do |r|
        lines = r.readlines
        return nil if lines.empty?

        targets = []
        for line in lines
            target = line.delete_suffix "\n"
            targets.push target
        end
        return targets
    end
rescue
    return nil        
end

if __FILE__ == $0
    pp get_go_targets
end