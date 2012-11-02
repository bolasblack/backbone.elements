do ($, _, Backbone) ->
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

  View = Backbone.View
  class Backbone.View extends View
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
      super @_parseSymbolSelector selector

    refreshElements: ->
      @undelegateEvents()
      for selector, varName of @elements
        delete this[@elementsPrefix + varName]
      @_refreshVarible()
      @_initElements()

    clearElements: ->
      for property in ["_reverseElements", "_elementsCache", "_regPrefix"]
        delete this[property]

    _configure: (options) ->
      super
      _.extend this, _.pick options, ["elements", "elementsPrefix"]
      @_initElements()

    _initElements: ->
      return unless @elements
      @_refreshVarible()

      for selector, varName of @elements
        do (selector, varName) =>
          selector = @_parseSymbolSelector selector
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

    _parseSymbol: (elementSymbol) ->
      elementNameRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)///
      elementName = elementSymbol.match(elementNameRE)[1]
      @_reverseElements[elementName] or elementSymbol

    _parseSymbolSelector: (selector) ->
      endReStr = @_elementsSymbolSpliter.join "|"
      elementsSelectorRE = ///#{@_regPrefix}([^#{@_negativeReStr()}]*)(?=#{endReStr}|$)///g
      while matchs = selector.match elementsSelectorRE
        elementSymbol = $.trim matchs[0]
        eventSelector = @_parseSymbol elementSymbol
        selector = selector.replace elementSymbol, eventSelector
      selector

    delegateEvents: (events) ->
      return super unless (events or= _.result this, "events")
      finalEvents = {}
      for selector, handerName of events
        newSelector = @_parseSymbolSelector selector
        finalEvents[newSelector] = handerName
      super finalEvents
