module.exports =
  getRandomString: (cun, uun)->
    userUN = this.removeSpecialCharacters(uun)
    cmpUN = this.removeSpecialCharacters(cun)
    d = new Date
    n = d.getTime().toString()
    randomGenerate = this.getSixCharRandom()
    strings = [userUN, cmpUN, n, randomGenerate]
    strings.join('')

  removeSpecialCharacters: (str) ->
    finalString = str.replace(/[^a-zA-Z0-9]/g, '')
    finalString.substr(0, 6).toLowerCase()

  getSixCharRandom: ->
    Math.random().toString(36).replace(/[^a-zA-Z0-9]+/g, '').substr(0, 6);