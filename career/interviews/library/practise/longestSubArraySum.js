function longestSubarraySumK(nums, k) {
	let prefixSum = 0;
	let maxLength = 0;

	const seen = new Map();
	seen.set(0, -1);

	console.log(`Target k = ${k}`);
	console.log(`Initial seen = { 0 → -1 }\n`);

	for (let i = 0; i < nums.length; i++) {
		console.log(`========== i = ${i}, nums[i] = ${nums[i]} ==========`);

		// 1. Add current number
		prefixSum += nums[i];

		console.log(`Running sum / prefixSum = ${prefixSum}`);

		// 2. Keep TARGET on right side:
		//
		// prefixSum - earlierPrefix = k
		//
		// therefore:
		//
		// earlierPrefix = prefixSum - k

		const needed = prefixSum - k;

		console.log(`${prefixSum} - earlierPrefix = ${k}`);

		console.log(`earlierPrefix = ${prefixSum} - ${k} = ${needed}`);

		// 3. Ask: did we ever have this earlier prefix?
		if (seen.has(needed)) {
			const earlierIndex = seen.get(needed);
			const length = i - earlierIndex;

			console.log(
				`✅ YES: prefixSum ${needed} was seen at index ${earlierIndex}`,
			);

			console.log(
				`Therefore subarray from index ${earlierIndex + 1} → ${i} sums to ${k}`,
			);

			console.log(`Length = ${i} - (${earlierIndex}) = ${length}`);

			maxLength = Math.max(maxLength, length);

			console.log(`maxLength = ${maxLength}`);
		} else {
			console.log(`❌ NO: prefixSum ${needed} has not been seen before`);
		}

		// 4. Store current prefix only if first occurrence
		if (!seen.has(prefixSum)) {
			seen.set(prefixSum, i);

			console.log(`Store prefixSum ${prefixSum} → index ${i}`);
		} else {
			console.log(
				`Don't overwrite prefixSum ${prefixSum}; earliest index is ${seen.get(prefixSum)}`,
			);
		}

		console.log(`seen =`, Object.fromEntries(seen));

		console.log('');
	}

	console.log(`FINAL maxLength = ${maxLength}`);

	return maxLength;
}

longestSubarraySumK([1, -1, 5, -2, 3], 3); // Output: 4
