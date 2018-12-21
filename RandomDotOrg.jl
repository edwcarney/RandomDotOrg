using HTTP, Printf

"""
    Get the current bit quota from Random.org
"""
function getQuota()
    r = HTTP.get("https://www.random.org/quota/?format=plain");
    return parse(Int, rstrip(String(r.body)))
end;

"""
    Test for sufficient quota to insure response. This should be set to match
    user's needs.
"""
function quotaCheck()
    return getQuota() >= 500
end;

"""
    Get `n` random integers on the interval `[min, max]`
    in one of 4 `base` values--[binary (2), octal (8), decimal (10), or hexadecimal (16)]
    All numbers are returned as strings (as Random.org sends them).

    # Arguments
    `base::Integer`: retrieved Integer format [2, 8, 10, 16]
    `check::Bool`: perform a call to `quotaCheck` before making request
    `col::Integer`: used to fulfill parameter requirments of random.org
"""
function randomNumbers(n = 100; min = 1, max = 20, base = 10, check = true, col = 5) 
    if (n < 1 || n > 10000) 
        return "Random number requests must be between 1 and 10,000 numbers"
    end
    if (min < -1f+09 || max > 1f+09 || min > max) 
        return "Random number range must be between -1000,000,000 and 1000,000,000"
    end
    if (!(base in [2, 8, 10, 16])) 
        return "Base has to be one of 2, 8, 10 or 16"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end

    urlbase = "https://www.random.org/integers/"
    urltxt = @sprintf("%s?num=%d&min=%d&max=%d&col=%d&base=%d&format=plain&rnd=new",
                            urlbase, n, Int(min), Int(max), col, base)
#     print(urltxt)
    response = HTTP.get( urltxt)
    return split(rstrip(String(response.body)))

end;

"""
    Get a randomized interval `[min, max]` -- (max - min + 1) randomized integers
    All numbers are returned as strings (as Random.org sends them).

    # Arguments
    `check::Bool`: perform a call to `quotaCheck` before making request
    `col::Integer`: used to fulfill parameter requirments of random.org
"""
function randomSequence(;min = 1, max = 20, col = 5, check = true)
    if (min < -1f+09 || max > 1f+09 || min > max) 
        return "Random number range must be between -1000,000,000 and 1000,000,000"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end
    urlbase = "https://www.random.org/sequences/"
    urltxt = @sprintf("%s?min=%d&max=%d&col=%d&format=plain&rnd=new",
                            urlbase, Int(min), Int(max), col)
#     print(urltxt)
    response = HTTP.get( urltxt)
    return split(rstrip(String(response.body)))
end;

"""
    Get `n` random strings of length `len`

    # Arguments
    `digits::Bool`: include digits in strings
    `upperalpha::Bool`: include upper case letters in strings
    `loweralpha::Bool`: include lowercase letters in strings
    `unique::Bool`: strings must be unique if `true`
"""
function randomStrings(n=10, len=5; digits=true, upperalpha=true, loweralpha=true, unique=true, check=true)
    if (n < 1 || n > 10000) 
        return "Random string requests must be between 1 and 10,000 numbers"
    end
    if (len < 1 || len > 20) 
        return "Random string length must be between 1 and 20"
    end
    if (typeof(digits) != Bool || typeof(upperalpha) != Bool || 
        typeof(loweralpha) != Bool || typeof(unique) != Bool) 
        return "The 'digits', '(lower|upper)alpha' and 'unique' arguments has to be logical"
    end
    if (!digits && !upperalpha && !loweralpha) 
        return "The 'digits', 'loweralpha' and 'loweralpha' cannot all be false at the same time"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end
    urlbase = "https://www.random.org/strings/"
    urltxt = @sprintf("%s?num=%d&len=%d&digits=%s&upperalpha=%s&loweralpha=%s&unique=%s&format=plain&rnd=new",
                            urlbase, n, len, ifelse(digits, "on", "off"),
                            ifelse(upperalpha, "on", "off"), ifelse(loweralpha, "on", "off"),
                            ifelse(unique, "on", "off"))
#     print(urltxt)
    response = HTTP.get( urltxt)
    return split(rstrip(String(response.body)))
end;

"""
    Get n numbers from a Gaussian distribution with `mean` and `stdev`.
    Returns strings in `dec` decimal places.
    Scientific notation only for now.
"""
function randomGaussian(n=10, mean=0.0, stdev=1.0; dec=10, col=2, notation="scientific", check=true)
    if (n < 1 || n > 10000) 
        return "Random string requests must be between 1 and 10,000 numbers"
    end
    if (mean < -1f+06 || mean > 1f+06)
        return "mean must be between -1,000,000 and 1,000,000"
    end
    if (stdev < -1f+06 || stdev > 1f+06)
        return "std dev must be between -1,000,000 and 1,000,000"
    end
    if (dec < 2 || dec > 20)
        return "decimal places must be between 2 and 20"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end
    urlbase = "https://www.random.org/gaussian-distributions/"
    urltxt = @sprintf("%s?num=%d&mean=%f&stdev=%f&dec=%d&col=%d&notation=%s&format=plain&rnd=new",
                            urlbase, n, mean, stdev, dec, col, notation)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return split(rstrip(String(response.body)))
end;

"""
    Get n decimal fractions on the interval (0,1).
    Returns strings in `dec` decimal places.
    Scientific notation only for now.
"""
function randomDecimalFractions(n=10; dec=10, col=2, check=true)
    if (n < 1 || n > 10000) 
        return "Random string requests must be between 1 and 10,000 numbers"
    end
    if (dec < 2 || dec > 20)
        return "decimal places must be between 2 and 20"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end
    urlbase = "https://www.random.org/decimal-fractions/"
    urltxt = @sprintf("%s?num=%d&dec=%d&col=%d&format=plain&rnd=new",
                            urlbase, n, dec, col)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return split(rstrip(String(response.body)))
end;

"""
    Get n random bytes.
    Returns strings in binary, decimal, octal, or hexadecimal.
    The request will also download a DMS file.
"""
function randomBytes(n=10; format="o", check=true)
    if (n < 1 || n > 10000) 
        return "Random string requests must be between 1 and 10,000 numbers"
    end
    if (!(format in ["b", "d", "o", "h", "file"])) 
        return "Base has to be one of 2, 8, 10 or 16"
    end
    if (check && !quotaCheck()) 
        return "random.org suggests to wait until tomorrow"
    end
    urlbase = "https://www.random.org/cgi-bin/randbyte"
    urltxt = @sprintf("%s?nbytes=%d^=&format=%s",
                            urlbase, n, format)
    # print(urltxt)
    # response = HTTP.get( urltxt)
    response = HTTP.get(urltxt)
    if (format == "file")
        return response.body
    else
        return split(rstrip(String(response.body)))
    end
end;
