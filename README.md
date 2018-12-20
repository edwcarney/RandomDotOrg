# RandomDotOrg.jl

Julia functions to provide support for random numbers obtained from the <a href="https://random.org" target="_blank">random.org</a> website.

<b>getQuota()</b>&mdash;obtain current bit quota for your IP.<br>
<b>checkQuota()</b>&mdash;check if quota is non-zero.<br>
<b>randomNumbers()</b>&mdash;obtain integers.<br>
<b>randomSequence()</b>&mdash;obtain randomized sequences of integers 1..N<br>
<b>randomStrings()</b>&mdash;obtain random strings of characters (upper/lower case letters, digits)<br>
<b>randomGaussian()</b>&mdash;obtain random Gaussian numbers<br>
<b>randomDecimalFractions()</b>&mdash;obtain random numbers on the interval (0,1)<br>
<b>randomBytes()</b>&mdash;obtain random bytes in various formats<br>

Simply include the file with include("RandomDotOrg.jl").

Values are returned in vector arrays of integers or strings.

It is probably best not to use the Random.org site for any purpose that might have a direct impact on security, such as using <b>randomStrings()</b> to create passwords.

using HTTP, Printf
