# Description:
#   Patch for taringa

module.exports = (robot) ->
  robot.respondPattern = (regex) ->
    re = regex.toString().split('/')
    re.shift()
    modifiers = re.pop()

    if re[0] and re[0][0] is '^'
      robot.logger.warning \
        "Anchors don't work well with respond, perhaps you want to use 'hear'"
      robot.logger.warning "The regex in question was #{regex.toString()}"

    pattern = re.join('/')
    name = robot.name.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')

    if robot.alias
      alias = robot.alias.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')
      [a,b] = if name.length > alias.length then [name,alias] else [alias,name]
      newRegex = new RegExp(
        "^\\s*(?:[@]?(?:#{a}[:,]?|#{b}[:,]?)\\s*|\\.)(?:#{pattern})"
        modifiers
      )
    else
      newRegex = new RegExp(
        "^\\s*(?:[@]?#{name}[:,]?\\s*|\\.)(?:#{pattern})",
        modifiers
      )
    newRegex