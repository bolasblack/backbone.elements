# Backbone.elements

**Add shortcut for Backbone.View selector**

## Install

```html
<script src="../lib/jquery-1.8.2.min.js" type="text/javascript"></script>
<script src="../lib/underscore-min.js" type="text/javascript"></script>
<script src="../lib/backbone-min.js" type="text/javascript"></script>
<script src="../lib/backbone.elements.js" type="text/javascript"></script>
```

## Usage

### Add a shortcut

```coffeescript
class View extends Backbone.View
  elements:
    ".elem-selector": "elem"
```

### Use shortcut

```coffeescript
class View extends Backbone.View
  elements:
    ".elem-selector": "elem"
    "$elem .child-elem"
  
  # use shortcut in event bind
  events:
    "click $elem": "_clickHandler"
    "mouseover $elem": "_hoverHandler"
    "dblclick $elem": "_dblclickHandler"
  
  # get element jquery object
  _clickHandler: ->
    @$elem().text "clicked"
    
  _dblclickHandler: ->
    @$elem().replaceWith $ "<div>", class: "loading elem-selector"
    # refresh elem cache
    @$elem(true).removeClass "loading"
    
  # select child element
  _hoverHandler: ->
    # use as `this.$`
    @$elem(".sub-elem").addClass "hover"
    # same as `@$elem().find(".sub-elem")`
    
    # use in `this.$`, **not recommend**, becase the
    # `$elem` shortcut cann't use the element cache
    @$("$elem .another-elem").removeClass "hover"
    # same as `@$(".elem-selector .another-elem")
```

### Refresh Element Cache

```coffeescript
class View extends Backbone.View
  elements:
    ".elem-selector": "elem"
  
  rerender: ->
    @render()
    @refreshCache()
```

### Parse Shortcut

```coffeescript
class View extends Backbone.View
  elements:
    ".elem-selector": "elem"
  
  events:
    "click $elem": "_clickHandler"
  
  _clickHandler: (event) ->
    $(document).on "hover", @parseSelectorSymbol("$elem .hotpoint"), (event) =>
      alert "hover"
```

### Dispose Element Cache

It will dispose element cache autonomicly when Backbone.View call `remove` method.

```coffeescript

class View extends Backbone.View
  elements:
    ".elem-selector": "elem"
  
  events:
    "click $elem": "_clickHandler"
  
  _clickHandler: (event) ->
    @clearElements()
```
