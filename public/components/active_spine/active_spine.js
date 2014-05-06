// Generated by CoffeeScript 1.7.1
var theme, themes,
  __slice = [].slice;

themes = ['slide', 'fade'];

theme = 'fade';

if (theme === 'slide') {
  Spine.stage = [{}, {}, {}];
  Spine.Stack.include({
    add: function(controller) {
      Spine.stage[2][controller.constructor.name] = controller;
      this.manager.add(controller);
      return this.append(controller);
    }
  });
  Spine.Manager.include({
    change: function() {
      var act, args, current, list, name, placement, _i, _len, _ref, _ref1, _ref2;
      current = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      ProgressBar.show();
      if ($("#buffer").length === 0) {
        $("<div id='buffer' style='left: 10000'/>").appendTo($("body"));
      }

      /*
      for cont in @controllers when cont isnt current
        cont.deactivate(args...)
      
        current.activate(args...) if current
       */
      _ref = Spine.stage;
      for (placement = _i = 0, _len = _ref.length; _i < _len; placement = ++_i) {
        list = _ref[placement];
        if (list[current.constructor.name] == null) {
          continue;
        }
        if (placement === 0) {
          _ref1 = Spine.stage[1];
          for (name in _ref1) {
            act = _ref1[name];
            act.offstage("left", function() {
              delete Spine.stage[1][this.constructor.name];
              return Spine.stage[2][this.constructor.name] = this;
            });
          }
          current.onstage("left", function() {
            delete Spine.stage[0][this.constructor.name];
            return Spine.stage[1][this.constructor.name] = this;
          });
        } else if (placement === 2) {
          _ref2 = Spine.stage[1];
          for (name in _ref2) {
            act = _ref2[name];
            act.offstage("right", function() {
              delete Spine.stage[1][this.constructor.name];
              return Spine.stage[0][this.constructor.name] = this;
            });
          }
          current.onstage("right", function() {
            delete Spine.stage[2][this.constructor.name];
            return Spine.stage[1][this.constructor.name] = this;
          });
        }
      }
      return ProgressBar.hide();
    }
  });
  Spine.Controller.include({
    onstage: function(dir, cb) {
      var effect;
      if (dir == null) {
        dir = null;
      }
      if (cb == null) {
        cb = null;
      }
      if (dir == null) {
        this.activate();
        if (cb != null) {
          cb.apply(this);
        }
        return this;
      }
      this.el.css("left", dir === "right" ? $(document).width() + 50 : -($(document).width() + 50));
      this.el.css("display", "block");
      effect = {};
      effect['left'] = 0;
      this.el.animate(effect, (function(_this) {
        return function() {
          _this.activate();
          return cb != null ? cb.apply(_this) : void 0;
        };
      })(this));
      return this;
    },
    offstage: function(dir, cb) {
      var effect;
      if (dir == null) {
        dir = null;
      }
      if (cb == null) {
        cb = null;
      }
      if (dir == null) {
        this.el.css("display", "none");
        this.deactivate();
        if (cb != null) {
          cb.apply(this);
        }
        return this;
      }
      effect = {};
      effect['left'] = dir === "right" ? -($(document).width() + 50) : $(document).width() + 50;
      this.el.animate(effect, (function(_this) {
        return function() {
          _this.el.css("display", "none");
          _this.deactivate();
          return cb != null ? cb.apply(_this) : void 0;
        };
      })(this));
      return this;
    }
  });
} else if (theme === 'fade') {
  Spine.Manager.include({
    change: function() {
      var args, cont, current, _i, _len, _ref;
      current = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.controllers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cont = _ref[_i];
        if (!(cont !== current)) {
          continue;
        }
        if (cont.el.hasClass('active')) {
          cont.el.fadeOut('fast');
        }
        cont.deactivate.apply(cont, args);
      }
      return current.el.css({
        opacity: 0,
        display: 'block'
      }).animate({
        opacity: 1
      }, Math.random() * 100 + 400, (function(_this) {
        return function() {
          return current.activate(args);
        };
      })(this));
    }
  });
}

if (Spine.Stack) {
  Spine.Stack.prototype.swap = {};
}

Spine.Controller.include({

  /*
  init: () ->
    console.log @stack
   */
  setStack: function(stack) {
    return Spine.Controller.prototype.stack = stack;
  },
  template: function(name) {
    var _ref;
    return (_ref = window.templates[name]) != null ? _ref : (function() {
      return "";
    });
  }
});
