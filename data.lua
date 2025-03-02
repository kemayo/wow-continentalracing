local myname, ns = ...

ns.extra_children = {
	-- Note: this is only needed for zones where a child-of-child is relevant,
	-- and the child-of-child will have data from GetMapRectOnMap
	[2274] = { -- Khaz Algar
		2339, -- Dornogal (technically a child of Isle of Dorn)
		2346, -- Undermine (technically a child of Ringing Deeps)
	},
}

local Race = function(achievements, currencies, coord, questID)
	return {
		achievements=achievements,
		currencies=currencies,
		coord=coord,
		questID=questID,
	}
end

ns.data = {
---- Dragonflight
-- Waking Shores (2022)
	-- base, advanced, reverse, challenge, challenge reverse
	-- [7261] = Race({}, {2082}, {2022, 73295208}) -- Waking Shores Rally
	-- need verification after advanced:
	[7740] = Race({15698, 15704, 17122, 17855, 17858}, {2042, 2044, 2154, 2421, 2422}, {2022, 63287085}, 72434), -- Ruby Lifeshrine Loop ? also has 2043 as "medium"
	[7741] = Race({15707, 15711, 17140, 17899, 17902}, {2046, 2047, 2176, 2423, 2424}, {2022, 62777395}, 66710), -- Flashfrost Flyover
	[7742] = Race({15714, 15717, 17125, 17861, 17864}, {2048, 2049, 2177, 2425, 2426}, {2022, 47048554}, 66721), -- Wild Preserve Slalom
	[7743] = Race({15726, 15729, 17128, 17867, 17870}, {2052, 2053, 2178, 2427, 2428}, {2022, 41966736}, 66727), -- Emberflow Flight
	[7744] = Race({15732, 15735, 17131, 17873, 17876}, {2054, 2055, 2179, 2429, 2430}, {2022, 23288426}, 66732), -- Apex Canopy River Run
	[7745] = Race({15738, 15741, 17134, 17886, 17889}, {2056, 2057, 2180, 2431, 2432}, {2022, 55434120}, 66777), -- Uktulut Coaster
	[7746] = Race({15744, 15747, 17137, 17893, 17896}, {2058, 2059, 2181, 2433, 2434}, {2022, 73183399}, 66786), -- Wingrest Roundabout
	[7747] = Race({15720, 15723, 17143, 17908, 17911}, {2050, 2051, 2182, 2435, 2436}, {2022, 42629453}, 66725), -- Wild Preserve Circuit
-- Ohn'ahran Plains (2023)
	-- base, advanced, reverse, challenge, challenge reverse
	[7748] = Race({15759, 15762, 17146, 17914, 17921}, {2060, 2061, 2183, 2437, 2439}, {2023, 63793053}, 66835), -- Sundapple Copse Circuit ?
	[7749] = Race({15765, 15768, 17149, 17924, 17927}, {2062, 2063, 2184, 2440, 2441}, {2023, 86243577}, 66877), -- Fen Flythrough ?
	[7750] = Race({15771, 15774, 17152, 17930, 17933}, {2064, 2065, 2185, 2442, 2443}, {2023, 80907213}, 66880), -- Ravine River Run ?
	[7751] = Race({15777, 15780, 17155, 17937, 17940}, {2066, 2067, 2186, 2444, 2445}, {2023, 25755505}, 66885), -- Emerald Garden Ascent ?
	[7752] = Race({16304, 16307, 17158, 17943, 17946}, {2119, 2120, 2187, 2448, 2449}, {2023, 43806681}, 70710), -- River Rapids Route ?
	--- base, challenge
	[7753] = Race({15784, 17949}, {2069, 2446}, {2023, 59963555}, 66921), -- Maruukai Dash ?
	[7754] = Race({15787, 17952}, {2070, 2447}, {2023, 47497062}, 66933), -- Mirror of the Sky Dash ({2024, 20811680})
-- Azure Span (2024)
	-- base, advanced, reverse, challenge, challenge reverse
	[7755] = Race({15790, 15793, 17161, 17955, 17958}, {2074, 2075, 2188, 2450, 2451}, {2024, 47894081}, 66946), -- The Azure Span Sprint ?
	[7756] = Race({15801, 15804, 17164, 17961, 17964}, {2076, 2077, 2189, 2452, 2453}, {2024, 20922259}, 67002), -- The Azure Span Slalom ?
	[7757] = Race({15820, 15823, 17167, 17967, 17970}, {2078, 2079, 2190, 2454, 2455}, {2024, 71312466}, 67031), -- The Vakthros Ascent ?
	[7758] = Race({15837, 15840, 17170, 17973, 17976}, {2083, 2084, 2191, 2456, 2457}, {2024, 16554932}, 67296), -- Iskaara Tour ?
	[7759] = Race({15843, 15846, 17173, 17981, 17984}, {2085, 2086, 2192, 2458, 2459}, {2024, 48453573}, 67565), -- Frostland Flyover ?
	[7760] = Race({15849, 15852, 17176, 17987, 17990}, {2089, 2090, 2193, 2460, 2461}, {2024, 42235677}, 67741), -- Archive Ambit ?
-- Thaldraszus (2025)
	-- base, advanced, reverse, challenge, challenge reverse
	[7761] = Race({15829, 15832, 17179, 17993, 17996}, {2080, 2081, 2194, 2462, 2463}, {2025, 57747499}, 67095), -- The Flowing Forest Flight
	[7762] = Race({15857, 15860, 17182, 17999, 18002}, {2092, 2093, 2195, 2464, 2465}, {2025, 57256685}, 69957), -- Tyrhold Trial
	[7763] = Race({15893, 15896, 17185, 18005, 18008}, {2096, 2097, 2196, 2466, 2467}, {2025, 37654893}, 70051), -- Cliffside Circuit ({2022, 67068405})
	[7764] = Race({15899, 15902, 17188, 18011, 18014}, {2098, 2099, 2197, 2468, 2469}, {2025, 60284177}, 70059), -- Academy Ascent
	[7765] = Race({15905, 15908, 17191, 18017, 18020}, {2101, 2102, 2198, 2470, 2471}, {2025, 39497622}, 70157), -- Garden Gallivant
	[7766] = Race({15911, 15914, 17194, 18023, 18026}, {2103, 2104, 2199, 2472, 2473}, {2025, 58043367}, 70161), -- Caverns Criss-Cross
-- Forbidden Reach (2151)
	-- base, advanced, reverse, challenge, challenge reverse
	[7767] = Race({17216, 17219, 17222, 18030, 18033}, {2201, 2207, 2213, 2474, 2475}, {2151, 76196574}, 73017), -- Stormsunder Crater Circuit
	[7768] = Race({17225, 17239, 17242, 18036, 18039}, {2202, 2208, 2214, 2476, 2477}, {2151, 31356588}, 73020), -- Morqut Ascent
	[7769] = Race({17245, 17248, 17251, 18042, 18045}, {2203, 2209, 2215, 2478, 2479}, {2151, 63165168}, 73025), -- Aerie Chasm Cruise
	[7770] = Race({17254, 17257, 17260, 18048, 18051}, {2204, 2210, 2216, 2480, 2481}, {2151, 63618432}, 73029), -- Southern Reach Route
	[7771] = Race({17263, 17266, 17269, 18054, 18057}, {2205, 2211, 2217, 2482, 2483}, {2151, 41401467}, 73033), -- Caldera Coaster
	[7772] = Race({17272, 17275, 17278, 18060, 18063}, {2206, 2212, 2218, 2484, 2485}, {2151, 49465996}, 73061), -- Forbidden Reach Rush
-- Zaralek Cavern (2133)
	-- ...none of these are flagged primary
	[7773] = Race({17431, 17434, 17437, 18066, 18069}, {2246, 2252, 2258, 2486, 2487}, {2133, 38746058}), -- Crystal Circuit
	[7774] = Race({17440, 17443, 17446, 18072, 18075}, {2247, 2253, 2259, 2488, 2489}, {2133, 39094989}), -- Caldera Cruise
	[7775] = Race({17449, 17452, 17455, 18078, 18081}, {2248, 2254, 2260, 2490, 2491}, {2133, 54512374}), -- Brimstone Scramble
	[7776] = Race({17458, 17461, 17464, 18084, 18087}, {2249, 2255, 2261, 2492, 2493}, {2133, 58704504}), -- Shimmering Slalom
	[7777] = Race({17467, 17470, 17473, 18090, 18093}, {2250, 2256, 2262, 2494, 2495}, {2133, 58065752}), -- Loamm Roamm
	[7778] = Race({17476, 17479, 17482, 18096, 18099}, {2251, 2257, 2263, 2496, 2497}, {2133, 51244665}), -- Sulfur Sprint

---- Kalimdor Cup
	-- base, advanced, reverse, challenge, reverse challenge
	[7494] = Race({17570, 17573, 17576, 18261, 18264}, {2312, 2342, 2372, 2498, 2499}), -- Felwood Flyover
	[7495] = Race({17579, 17582, 17585, 18267, 18270}, {2313, 2343, 2373, 2500, 2501}), -- Winter Wander
	[7496] = Race({17588, 17591, 17594, 18274, 18277}, {2314, 2344, 2374, 2502, 2503}), -- Nordrassil Spiral
	[7497] = Race({17597, 17600, 17603, 18280, 18283}, {2315, 2345, 2375, 2504, 2505}), -- Hyjal Hotfoot
	[7498] = Race({17606, 17609, 17612, 18287, 18290}, {2316, 2346, 2376, 2506, 2507}), -- Rocketway Ride
	[7499] = Race({17615, 17618, 17621, 18293, 18296}, {2317, 2347, 2377, 2508, 2509}), -- Ashenvale Ambit
	[7500] = Race({17624, 17627, 17630, 18299, 18302}, {2318, 2348, 2378, 2510, 2511}), -- Durotar Tour
	[7501] = Race({17633, 17636, 17639, 18305, 18308}, {2319, 2349, 2379, 2512, 2513}), -- Webwinder Weave
	[7502] = Race({17642, 17645, 17648, 18311, 18314}, {2320, 2350, 2380, 2514, 2515}), -- Desolace Drift
	[7503] = Race({17651, 17654, 17657, 18317, 18320}, {2321, 2351, 2381, 2516, 2517}), -- Great Divide Dive
	[7504] = Race({17660, 17663, 17666, 18323, 18326}, {2322, 2352, 2382, 2518, 2519}), -- Razorfen Roundabout
	[7505] = Race({17669, 17672, 17675, 18329, 18332}, {2323, 2353, 2383, 2520, 2521}), -- Thousand Needles Thread
	[7506] = Race({17678, 17681, 17684, 18335, 18338}, {2324, 2354, 2384, 2522, 2523}), -- Feralas Ruins Ramble
	[7507] = Race({17687, 17690, 17693, 18341, 18344}, {2325, 2355, 2385, 2524, 2525}), -- Ahn'Qiraj Circuit
	[7508] = Race({17696, 17699, 17702, 18347, 18350}, {2326, 2356, 2386, 2526, 2527}), -- Uldum Tour
	[7509] = Race({17705, 17708, 17711, 18353, 18356}, {2327, 2357, 2387, 2528, 2529}), -- Un'Goro Crater Circuit
	-- Also these in the currency table?
	-- {2328, 2358, 2388} -- Kalimdor 17
	-- {2329, 2359, 2389} -- Kalimdor 18
	-- {2330, 2360, 2390} -- Kalimdor 19
	-- {2331, 2361, 2391} -- Kalimdor 20
	-- {2332, 2362, 2392} -- Kalimdor 21
	-- {2333, 2363, 2393} -- Kalimdor 22
	-- {2334, 2364, 2394} -- Kalimdor 23
	-- {2335, 2365, 2395} -- Kalimdor 24
	-- {2336, 2366, 2396} -- Kalimdor 25
	-- {2337, 2367, 2397} -- Kalimdor 26
	-- {2338, 2368, 2398} -- Kalimdor 27
	-- {2339, 2369, 2399} -- Kalimdor 28
	-- {2340, 2370, 2400} -- Kalimdor 29
	-- {2341, 2371, 2401} -- Kalimdor 30
}

