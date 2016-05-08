import unittest, jsonwriter

suite "jsonwriter":
  test "empty root object":
    var w = newJsonWriter()
    w.rootObj(proc() = discard)
    check($w == "{}")

  test "empty root array":
    var w = newJsonWriter()
    w.rootArray(proc() = discard)
    check($w == "[]")

  test "key+values":
    var w = newJsonWriter()
    w.rootObj(proc() =
      w.write("over", 9000)
      w.write("fear", false)
      w.write("spice", true)
      w.write("and", '!')
      w.write("abc", 1.2)
    )
    check($w == """{"over":9000,"fear":false,"spice":true,"and":"!","abc":1.2}""")

  test "nested":
    var w = newJsonWriter()
    w.rootObj(proc() =
      w.obj("over", proc() =
        w.write("9000", true)
        w.array("levels", proc() =
          w.write(1)
          w.write("two")
        )
      )
    )
    check($w == """{"over":{"9000":true,"levels":[1,"two"]}}""")
