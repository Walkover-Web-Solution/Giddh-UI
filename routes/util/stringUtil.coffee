module.exports =
  getRandomString: (firstString, secondString)->
    firstString = this.removeSpecialCharacters(firstString)
    secondString = this.removeSpecialCharacters(secondString)
    d = new Date
    dateString = d.getTime().toString()
    randomGenerate = this.getSixCharRandom()
    strings = [firstString, secondString, dateString, randomGenerate]
    strings.join('')

  removeSpecialCharacters: (str) ->
    finalString = str.replace(/[^a-zA-Z0-9]/g, '')
    finalString.substr(0, 6).toLowerCase()

  getSixCharRandom: ->
    Math.random().toString(36).replace(/[^a-zA-Z0-9]+/g, '').substr(0, 6)