
module collectd.bimap;

import collectd.collection;

abstract class Bimap(K,V) : AbstractCollection!(Entry!(K,V))
{

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
		return this.length == 0;
	}

	void add(Entry!(K,V) entry) {
		add(entry.key, entry.val);
	}

	void add(K key, V val) {
		map[key] = val;
		rMap[val] = key;
	}

	V getVal(K key) {
		return map[key];
	}

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
