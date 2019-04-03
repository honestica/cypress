$errUtils = require("../../../../src/cypress/error_utils.js")

describe "driver/src/cypress/error_utils", ->
  context ".appendErrMsg", ->
    it "appends error message", ->
      err = new Error("foo")

      expect(err.message).to.eq("foo")
      expect(err.name).to.eq("Error")

      stack = err.stack.split("\n").slice(1).join("\n")

      err2 = $errUtils.appendErrMsg(err, "bar")
      expect(err2.message).to.eq("foo\n\nbar")

      expect(err2.stack).to.eq("Error: foo\n\nbar\n" + stack)

    it "handles error messages matching first stack", ->
      err = new Error("r")

      expect(err.message).to.eq("r")
      expect(err.name).to.eq("Error")

      stack = err.stack.split("\n").slice(1).join("\n")

      err2 = $errUtils.appendErrMsg(err, "bar")
      expect(err2.message).to.eq("r\n\nbar")

      expect(err2.stack).to.eq("Error: r\n\nbar\n" + stack)

    it "handles empty error messages", ->
      err = new Error()

      expect(err.message).to.eq("")
      expect(err.name).to.eq("Error")

      stack = err.stack.split("\n").slice(1).join("\n")

      err2 = $errUtils.appendErrMsg(err, "bar")
      expect(err2.message).to.eq("\n\nbar")

      expect(err2.stack).to.eq("Error: \n\nbar\n" + stack)
    
    it "handles error messages as objects", ->
      err = new Error("foo")

      obj = {
        message: "bar",
        docsUrl: "baz"
      }

      stack = err.stack.split("\n").slice(1).join("\n")

      err2 = $errUtils.appendErrMsg(err, obj)

      expect(err2.message).to.eq("foo\n\nbar")
      expect(err2.docsUrl).to.eq("baz")
      expect(err2.stack).to.eq("Error: foo\n\nbar\n" + stack)

  context ".cloneErr", ->
    it "copies properies, message, stack", ->
      obj = {
        stack: "stack"
        message: "message"
        name: "Foo"
        code: 123
      }

      err = $errUtils.cloneErr(obj)

      expect(err).to.be.instanceof(top.Error)

      for key, val of obj
        expect(err[key], "key: #{key}").to.eq(obj[key])

  context ".throwErr", ->
    it "throws err", ->
      fn = ->
        $errUtils.throwErrByPath('dom.animating', { args: {
          cmd: 'click',
          node: '<span></span>'
        }})

      expect(fn).to.throw()

  context ".throwErrByPath", ->
    it "throws err", ->
      fn = ->
        $errUtils.throwErrByPath('dom.animating', { args: {
          cmd: 'click',
          node: '<span></span>'
        }})

      expect(fn).to.throw()

  context ".formatErrMsg", ->
    it "returns obj with mdMessage when includeMdMessage", ->
        err = $errUtils.formatErrMsg("`foo`\n\nbar", {includeMdMessage: true})
        expect(err.message).to.eq("`foo`\n\nbar")
        expect(err.mdMessage).to.eq("`foo`\n\nbar")

    it "returns string msg when no includeMdMessage", ->
      err = $errUtils.formatErrMsg("`foo`\n\nbar")
      expect(err).to.eq("`foo`\n\nbar")

  context ".errObjByPath", ->
    it "returns obj when err is object", ->
      msg = $errUtils.errMsgByPath('uncaught.fromApp')
      expect(msg).to.be.an.object

    it "returns obj when err is string", ->
      msg = $errUtils.errMsgByPath('chai.match_invalid_argument', {
        regExp: 'foo'
      })

      expect(msg).to.be.an.object

    it "returns obj when err is function"

  context ".errMsgByPath", ->
    it "returns the message when err is object", ->
      msg = $errUtils.errMsgByPath('uncaught.fromApp')
      expect(msg).to.include("This error originated from your application code, not from Cypress.")

    it "returns the message when err is string", ->
      msg = $errUtils.errMsgByPath('chai.match_invalid_argument', {
        regExp: 'foo'
      })

      expect(msg).to.eq("`match` requires its argument be a `RegExp`. You passed: `foo`")

    it "returns the message when err is function"

  context ".getCodeFrame", ->
    it "returns a code frame with syntax highlighting", ->
      path = "foo/bar/baz"
      line = 5
      column = 6
      src = """
        <!DOCTYPE html>
        <html>
        <body>
          <script type="text/javascript">
            foo.bar()
          </script>
        </body>
        </html>
      """

      { frame, path, lineNumber, columnNumber } = $errUtils.getCodeFrame(src, path, line, column)

      expect(frame).to.contain("foo")
      expect(frame).to.contain("bar()")
      expect(frame).to.contain("[0m")
      expect(path).to.eq("foo/bar/baz")
      expect(lineNumber).to.eq(5)
      expect(columnNumber).to.eq(6)

    ## TODO determine if we want more failure cases covered
    it "returns empty string when code frame can't be generated", ->
      path = "foo/bar/baz"
      line = 100 ## There are not 100 lines in src
      column = 6
      src = """
        <!DOCTYPE html>
        <html>
        <body>
          <script type="text/javascript">
            foo.bar()
          </script>
        </body>
        </html>
      """

      { frame } = $errUtils.getCodeFrame(src, path, line, column)

      expect(frame).to.eq("")

  context ".escapeErrMarkdown", ->
    it "accepts non-strings", ->
      text = 3
      expect($errUtils.escapeErrMarkdown(text)).to.equal(3)

    it "escapes backticks", ->
      md = "`foo`"
      expect($errUtils.escapeErrMarkdown(md)).to.equal("\\`foo\\`")