do (jQuery, _, Backbone, console) ->
  nop = ->
  console ?= {log: nop, warn: nop, error: nop}

  reEscape = (str, skipChar=[]) ->
    reSpecialChar = [
      "\\", "/", ",", "."
      "|", "^", "$", "?"
      "+", "*", "[", "]"
      "{", "}", "(", ")"
    ]
    for char in reSpecialChar when char not in skipChar
      re = RegExp "\\" + char, "g"
      str = str.replace re, "\\#{char}"
    str

  {$: original$, _configure, delegateEvents} = Backbone.View.prototype
  _.extend Backbone.View.prototype,
    elementsPrefix: "$"
    _elementsSymbolSpliter: [
      # normal selector
      "\\#", "\\."
      # combo selector
      "\\,", "\\s", "\\>", "\\+", "\\~"
      # attribute selector
      "\\["
      # special selector
      "\\:"
    ]

    $: (selector) ->
      original$.call this, @parseSelectorSymbol selector

    refreshElements: ->
      @undelegateEvents()
      for selector, varName of @elements
        delete this[@elementsPrefix + varName]
      @_initElements()
      @delegateEvents()

    clearElements: ->
      for property in ["_reverseElements", "_elementsCache", "_regPrefix"]
        delete this[property]

    parseSelectorSymbol: (selector) ->
      endReStr = @_elementsSymbolSpliter.join "|"
      elementsSelectorRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)(?=#{endReStr}|$)///g
      cannotParseSymbols = []
      elementSymbol = null
      while (do (selector, elementsSelectorRE) =>
        matchs = selector.match(elementsSelectorRE)
        return false unless matchs
        elementSymbol = jQuery.trim matchs[0]
        return false if elementSymbol in cannotParseSymbols
        true
      )

        parsedSelector = @_parseSymbol elementSymbol
        if elementsSelectorRE.test parsedSelector
          cannotParseSymbols.push elementSymbol
          console.warn "element symbol", elementSymbol, "not exist"
        else
          selector = selector.replace elementSymbol, parsedSelector
      selector

    _configure: (options) ->
      _configure.apply this, arguments
      _.extend this, _.pick options, ["elements", "elementsPrefix"]
      @_initElements()

    _parseSymbol: (elementSymbol) ->
      elementNameRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)///
      elementName = elementSymbol.match(elementNameRE)[1]
      @_reverseElements[elementName] or elementSymbol

    _initElements: ->
      return unless @elements
      @_refreshVarible()

      for selector, varName of @elements
        do (selector, varName) =>
          selector = @parseSelectorSymbol selector
          this[@elementsPrefix + varName] = (subSelector, refresh) =>
            if subSelector in [true, false]
              [subSelector, refresh] = [undefined, subSelector]
            $elem = if refresh
              @$ selector
            else
              @_elementsCache[varName] or @$ selector
            return $elem unless $elem.length
            @_elementsCache[varName] = $elem
            return $elem unless subSelector
            $elem.find subSelector

    _refreshVarible: ->
      @_reverseElements = _.object ([v, k] for k, v of @elements)
      @_regPrefix = reEscape @elementsPrefix
      @_elementsCache = {}

    _negativeReStr: ->
      (@_elementsSymbolSpliter.join "") + @_regPrefix

    delegateEvents: (events) ->
      unless (events or= _.result this, "events")
        return delegateEvents.apply this, arguments
      finalEvents = {}
      for selector, handerName of events
        newSelector = @parseSelectorSymbol selector
        finalEvents[newSelector] = handerName
      delegateEvents.call this, finalEvents
