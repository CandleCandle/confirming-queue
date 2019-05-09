use "ponytest"
use "promises"
use "../confirming-queue"


actor _TestConsumer
    let _received: Array[String] = Array[String]()
    let delay: USize

    new create(delay': USize = 0) =>
        delay = delay'

    be handle(s: String, p: Promise[Bool]) =>
        _received.push(s)
        @sleep[None](delay)
        p(true)

    be received(p: Promise[Array[String] val]) =>
        let s = _received.size()
        let a: Array[String] iso = recover iso Array[String](s) end
        for v in _received.values() do a.push(v) end
        p(consume a)

actor TestConfirmingQueue is TestList
	new create(env: Env) =>
		PonyTest(env, this)

	new make() => None

	fun tag tests(test: PonyTest) =>
		let tests' = _all_tests()
		while tests'.size() > 0 do
			try test(tests'.pop()?) end
		end

	fun tag _all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "confirming-queue/publish/1"
	fun apply(h: TestHelper) =>
        h.long_test(2_000_000_000)
        let consumer = _TestConsumer
        let undertest = ConfirmingQueue(recover iso consumer~handle() end)
        undertest.publish("first")

        @sleep[None](USize(1)) // TODO have a way to notify the test that it can continue rather than have a sleep here, as it ensures that the test will always take at least 1 second.
        let complete = Promise[Array[String] val]
        complete
            .next[None]({(a: Array[String] val) => 
                h.assert_eq[String]("first", try a(0)? else "failed" end)
                h.complete(true)
            })
        consumer.received(complete)
end
object iso is UnitTest
	fun name(): String => "confirming-queue/publish/2"
	fun apply(h: TestHelper) =>
        h.long_test(2_000_000_000)
        let consumer = _TestConsumer
        let undertest = ConfirmingQueue(recover iso consumer~handle() end)
        undertest.publish("first")
        undertest.publish("second")

        @sleep[None](USize(1))
        let complete = Promise[Array[String] val]
        complete
            .next[None]({(a: Array[String] val) => 
                h.assert_eq[String]("first", try a(0)? else "failed 1" end)
                h.assert_eq[String]("second", try a(1)? else "failed 2" end)
                h.complete(true)
            })
        consumer.received(complete)
end

]