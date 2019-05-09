use "ponytest"
use "../confirming-queue"

actor Main is TestList
	new create(env: Env) =>
		PonyTest(env, this)
	new make() => None
	fun tag tests(test: PonyTest) =>
		TestConfirmingQueue.make().tests(test)
