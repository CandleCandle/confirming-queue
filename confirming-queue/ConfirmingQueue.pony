use "promises"
use "collections"


// transactional dispatch of queue elements.
actor ConfirmingQueue
	var in_progress: Bool = false
	let queue: List[String] = List[String]

	let cb: {(String, Promise[Bool])} iso

	new create(cb': {(String, Promise[Bool])} iso) =>
        """
        This callback is called for every entry in the queue, in order
        of the entries arrival. When all processing of of the
        entry has been done, then the supplied Promise must be fulfilled.
        """
		cb = consume cb'

	be publish(s: String) =>
        """
        Add an element to the queue
        """
		queue.push(s)
		_dispatch()

	be _complete() =>
        """
        Mark the currently processing entry as complete.
        """
		in_progress = false

	be _dispatch() =>
        """
        Attempt to drain the queue by calling the callback and
        waiting for the promise to be completed.
        """
		if in_progress then return end
		if queue.size() > 0 then
			in_progress = true
			let promise: Promise[Bool] = Promise[Bool]
			let t = recover tag this end
			promise
				.next[None](recover iso {(b: Bool) =>
					t._complete()
					t._dispatch()
				} end)
			
			try cb(queue.shift()?, promise) end // Given the prior check for `size() > 0` this cannot raise an error.
		end
