Confirming Queue
================

Provides a buffer of messages that need to be processed in-order when the receiving actor, particularly when the receiving actor requires input from other actors in order to complete it's processing.


Sample Usage
------------

```pony
actor LongTask
    var _state: String
    be get_state(callback: {(state: String val)}) => // e.g. database query
        @sleep[None](USize(2)) // emmulate this task taking a significant amount of time
        callback(_state.clone())

actor Consumer
    let _long_task: LongTask = LongTask

    be handle(in_order_message: String, complete: Promise[Bool]) =>
        _long_task.get_state({(state: String val) =>
            @printf[None]("handled %s with %s\n".cstring(), in_order_message, state)
            update_internal_state()
            complete(true)
        })

actor Main()
    new create(env: Env) =>
        let consumer = Consumer
        let queue: ConfirmingQueue(recover iso consumer~handle end)

        queue.publish("first")
        queue.publish("second")
```