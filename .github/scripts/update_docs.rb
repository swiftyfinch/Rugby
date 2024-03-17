DOCS_GLOB = 'Docs/**/*.md'
SHELL_BLOCK_REGEX = "```sh\n(.*?)\n```"
COMMAND_PREFIX = '> '
COMMAND_SUFFIX = '--help'

Dir.glob(DOCS_GLOB).each do |file|
  content = File.read(file)
  next unless matches = content.scan(/#{SHELL_BLOCK_REGEX}/m) and matches.length > 1

  command = matches[0][0].to_s
  next unless command.start_with?(COMMAND_PREFIX) and command.end_with?(COMMAND_SUFFIX)
  command = command.delete_prefix(COMMAND_PREFIX)

  current_help = matches[1][0].to_s
  help = `#{command}`
  help.sub!(/\si\s.*/m, '') # Remove a block with links
  help.sub!(/╭─*╮\n│\s*│[\s\S]*?╯\n\n/, '') # Remove the header with version

  help.delete_suffix!("\n\n")

  next if current_help == help
  updated_content = content.gsub(current_help, help)
  File.write(file, updated_content)
  puts "Updated: #{file}"
end
