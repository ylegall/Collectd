
module collectd.util.string;


import std.conv;

class StringBuilder
{
	private {
		size_t len = 0;
		char[] str = [];
	}

	this (string s = "") {
		str = s.dup;
		len = s.length;
	}

	auto append(T)(T item) {
		static if (is(T == string)) {
			appendString(item);
		} else {
			appendString(to!string(item));
		}
		return this;
	}

	private void appendString(string s) {
		auto newLen = len + s.length;
		if (newLen > str.length) {
			str.length +=  cast(size_t)(newLen * 1.5);
		}
		str[len .. len + s.length] = s;
		len += s.length;
	}

	void clear() {
		len = 0;
		str = [];
	}

	string toString() {
		return to!string(str[0 .. len]);
	}

	auto opBinary(string op, T)(T rhs) {
		static if (op == "~") {
			return append(rhs);
		}
	}

}

version(string)
{
	import std.stdio;
	import std.datetime;

	void main()
	{
		const MAX = 1000000;

		StopWatch sw;

		auto sb = new StringBuilder();
		sw.start();
		foreach (i; 0 .. MAX) {
			sb = sb ~ "hello ";
			sb = sb ~ "world ";
			sb = sb ~ 42;
			sb.clear();
		}
		sw.stop();
		writeln("string builder time: ", sw.peek().msecs);

		sw.reset();

		string s = "";
		sw.start();
		foreach (i; 0 .. MAX) {
			s = s ~ "hello ";
			s = s ~ "world ";
			s = s ~ to!string(42);
		}
		sw.stop();
		writeln("string time: ", sw.peek().msecs);
	}
}

