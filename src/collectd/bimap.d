
module collectd.bimap;

import collectd.collection;


abstract class Bimap(K,V) : AbstractCollection!(Entry!(K,V))
{
	bool containsKey(K key);
	bool containsValue(V val);
}


struct Entry(K, V)
{
	K key;
	V val;
}


class HashBimap(K,V) : Bimap!(K,V)
{
	private
	{
		V[K] map;
		K[V] rMap;
	}

	this() {

	}

	override void clear() {
		map = empty_map!(K,V)().dup;
		rMap = empty_map!(V,K)().dup;
	}

	@property
	size_t length() {
		return map.keys.length;
	}

	@property
	bool isEmpty() {
		return this.len == 0;
	}

	void add(Entry!(K,V) entry) {
		add(entry.key, entry.val);
	}

	void add(K key, V val) {
		map[key] = val;
		rMap[val] = key;
	}
	alias add put;

	V getVal(K key) {
		return map[key];
	}
	alias getVal get;

	K getKey(V val) {
		return rMap[val];
	}

	bool containsKey(K key) {
		return (key in map) != null;
	}

	bool containsValue(V val) {
		return val in rMap;
	}

	void removeKey(K key) {
		auto v = map[key];
		map[key].remove();
		rMap[v].remove();
	}

	void removeValue(V val) {
		auto k = rMap[val];
		rMap[val].remove();
		map[k].remove();
	}

	mixin MapIndexor!(K,V);

}

unittest {
	auto bm = new HashBimap!(int,int)();
	bm.add(1,2);
	bm.add(4,5);
	assert(bm.containsKey(1));
	assert(bm.containsValue(2));
	assert(!bm.containsKey(2));
	assert(!bm.containsValue(4));
}

version (bimap) {
	import std.stdio;
	void main() {
		auto bm = new HashBimap!(int,int)();
		bm.add(1,2);
		bm.add(4,5);
		writeln(bm.containsKey(1));
		writeln(bm.containsKey(2));
		writeln(bm.containsValue(4));
		writeln(bm.containsValue(5));
	}
}
