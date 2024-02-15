/**
 * Returns items that are in Set A but not Set B
 *
 * @param setA Set A
 * @param setB Set B
 * @returns Items in Set A but not Set B
 */
function difference<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _difference = new Set<T>(setA);
	for (const elem of setB) {
		_difference.delete(elem);
	}
	return _difference;
}

/**
 * Returns items that are in both Set A and Set B
 *
 * @param setA Set A
 * @param setB Set B
 * @returns Items in both Set A and Set B
 */
function intersection<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _intersection = new Set<T>();
	for (const elem of setB) {
		if (setA.has(elem)) {
			_intersection.add(elem);
		}
	}
	return _intersection;
}

/**
 * Returns true if all items in subset are also in superset. Superset may also contain additional
 * items that are not in the subset.
 *
 * @param superset Superset
 * @param subset Subset
 * @returns True if superset contains all items in subset, false otherwise.
 */
function isSuperset<T>(superset: Set<T>, subset: Set<T>): boolean {
	for (const elem of subset) {
		if (!superset.has(elem)) {
			return false;
		}
	}

	return true;
}

/**
 * ?
 *
 * @param setA Set A
 * @param setB Set B
 * @returns ?
 */
function symmetricDifference<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _difference = new Set<T>(setA);
	for (const elem of setB) {
		if (_difference.has(elem)) {
			_difference.delete(elem);
		} else {
			_difference.add(elem);
		}
	}
	return _difference;
}

/**
 * ?
 *
 * @param setA Set A
 * @param setB Set B
 * @returns ?
 */
function union<T>(setA: Set<T>, setB: Set<T>): Set<T> {
	const _union = new Set<T>(setA);
	for (const elem of setB) {
		_union.add(elem);
	}
	return _union;
}

export { difference, intersection, isSuperset, symmetricDifference, union };
