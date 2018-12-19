# RandomDotOrg.jl

Julia functions to provide support for random numbers obtained from the random.org website.

<b>getQuota()</b>&mdash;obtain current bit quota for your IP.<br>
<b>checkQuota()</b>&mdash;check if quota is non-zero.<br>
<b>randomNumbers()</b>&mdash;obtain integers.<br>
<b>randomSequence()</b>&mdash;obtain randomized sequences of integers 1..N<br>
<b>randomStrings()</b>&mdash;obtain random strings of characters (upper/lower case letters, digits)<br>

Simply include the file with include("RandomDotOrg.jl").

Values are returned in vector arrays of integers or strings.

using HTTP, Printf
