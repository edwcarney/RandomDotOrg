module RandomDotOrg

using HTTP, Printf

export  getQuota, checkQuota, randomNumbers, randomSequence, randomStrings, randomGaussian,
        randomDecimalFractions, randomBytes

"""
    Get the current bit quota from Random.org
"""
function getQuota()
    r = HTTP.get("https://www.random.org/quota/?format=plain");
    return parse(Int64, rstrip(String(r.body)))
end;

"""
    Test for sufficient quota to insure response. This should be set to match
    user's needs.
"""
function checkQuota(minimum = 500::Number)
    return getQuota() >= minimum
end;

"""
    Get `n` random integers on the interval `[min, max]`
    in one of 4 `base` values--[binary (2), octal (8), decimal (10), or hexadecimal (16)]
    All numbers are returned as strings (as Random.org sends them).

    # Arguments
    `base::Integer`: retrieved Integer format [2, 8, 10, 16]
    `check::Bool`: perform a call to `checkQuota` before making request
    `col::Integer`: used to fulfill parameter requirments of random.org
"""
function randomNumbers(n = 100::Number; min = 1, max = 20, base = 10, check = true, col = 5) 
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (min < -1f+09 || max > 1f+09 || min > max) && return "Range must be between -1e9 and 1e9"

    (!(base in [2, 8, 10, 16])) && return "Base has to be one of 2, 8, 10 or 16"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/integers/"
    urltxt = @sprintf("%s?num=%d&min=%d&max=%d&col=%d&base=%d&format=plain&rnd=new",
                    urlbase, n, Int(min), Int(max), col, base)
#     print(urltxt)
    response = HTTP.get( urltxt)
    return [parse(Int64, x) for x in split(rstrip(String(response.body)))]

end;

"""
    Get a randomized interval `[min, max]` -- (max - min + 1) randomized integers
    All numbers are returned as strings (as Random.org sends them).

    # Arguments
    `check::Bool`: perform a call to `checkQuota` before making request
    `col::Integer`: used to fulfill parameter requirments of random.org
"""
function randomSequence(;min = 1::Number, max = 20::Number, col = 5, check = true)
    (min < -1f+09 || max > 1f+09 || min > max) && return "Range must be between -1e9 and 1e9"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"
 
    urlbase = "https://www.random.org/sequences/"
    urltxt = @sprintf("%s?min=%d&max=%d&col=%d&format=plain&rnd=new",
                    urlbase, Int(min), Int(max), col)
    response = HTTP.get( urltxt)
    return [parse(Int64, x) for x in split(rstrip(String(response.body)))]
end;

"""
    Get `n` random strings of length `len`

    # Arguments
    `digits::Bool`: include digits in strings
    `upperalpha::Bool`: include upper case letters in strings
    `loweralpha::Bool`: include lowercase letters in strings
    `unique::Bool`: strings must be unique if `true`
"""
function randomStrings(n=10::Number, len=5; digits=true, upperalpha=true, loweralpha=true, unique=true, check=true)
    (n < 1 || n > 10000) && return "1 to 10,000 requests only"

    (len < 1 || len > 20) && return "Length must be between 1 and 20"

    (typeof(digits) != Bool || typeof(upperalpha) != Bool || typeof(loweralpha) != Bool || typeof(unique) != Bool) && return "The 'digits', '(lower|upper)alpha' and 'unique' arguments have to be logical"

    (!digits && !upperalpha && !loweralpha) && return "The 'digits', 'loweralpha' and 'upperalpha' cannot all be false"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/strings/"
    urltxt = @sprintf("%s?num=%d&len=%d&digits=%s&upperalpha=%s&loweralpha=%s&unique=%s&format=plain&rnd=new",
                urlbase, n, len, ifelse(digits, "on", "off"),
                ifelse(upperalpha, "on", "off"), ifelse(loweralpha, "on", "off"),
                ifelse(unique, "on", "off"))
#     print(urltxt)
    response = HTTP.get( urltxt)
    split(rstrip(String(response.body)))
end;

"""
    Get n numbers from a Gaussian distribution with `mean` and `stdev`.
    Returns strings in `dec` decimal places.
    Scientific notation only for now.
"""
function randomGaussian(n=10::Number, mean=0.0, stdev=1.0; dec=10, col=2, notation="scientific", check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (mean < -1f+06 || mean > 1f+06) && return "Mean must be between -1e6 and 1e6"

    (stdev < -1f+06 || stdev > 1f+06) && return "Std dev must be between -1e6 and 1e6"

    (dec < 2 || dec > 20) && return "Decimal places must be between 2 and 20"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/gaussian-distributions/"
    urltxt = @sprintf("%s?num=%d&mean=%f&stdev=%f&dec=%d&col=%d&notation=%s&format=plain&rnd=new",
                    urlbase, n, mean, stdev, dec, col, notation)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return [parse(Float64, x) for x in split(rstrip(String(response.body)))]
end;

"""
    Get n decimal fractions on the interval (0,1).
    Returns strings in `dec` decimal places.
"""
function randomDecimalFractions(n=10::Number; dec=10, col=2, check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (dec < 2 || dec > 20) && return "Decimal places must be between 2 and 20"

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/decimal-fractions/"
    urltxt = @sprintf("%s?num=%d&dec=%d&col=%d&format=plain&rnd=new",
                        urlbase, n, dec, col)
    # print(urltxt)
    response = HTTP.get( urltxt)
    return [parse(Float64, x) for x in split(rstrip(String(response.body)))]
end;

"""
    Get n random bytes.
    Returns strings in binary, decimal, octal, or hexadecimal.
    The request will also download a DMS file.
"""
function randomBytes(n=10::Number; format="o", check=true)
    (n < 1 || n > 10000) && return "Requests must be between 1 and 10,000 numbers"

    (!(format in ["b", "d", "o", "h", "file"])) && return "Format must be one of b, d, o, h, or file."

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    urlbase = "https://www.random.org/cgi-bin/randbyte"
    urltxt = @sprintf("%s?nbytes=%d^=&format=%s",
                        urlbase, n, format)
    # print(urltxt)
    # response = HTTP.get( urltxt)
    response = HTTP.get(urltxt)
    if (format == "file")
        return response.body
    else 
        return [parse(Int64, x) for x in split(rstrip(String(response.body)))]
    end
end

"""
    Get a random bitmap.
    Returns bitmap as PNG or GIF.

    # Arguments
    `format::String`: png or gif
    `height, width`: 1-300 pixels in each dimension
    `save`: filename/filepath to write file (extension added by default)
    `overwrite`: will not overwrite by default; set to 'y' to overwrite
"""
function randomBitmap(format="png"; width=64, height=64, save="", overwrite='n', check=true)
    (!(format in ["png", "gif"])) && return "Format must be png or gif."

    (width < 1 || width > 300 || height < 1 || height > 300) && return "Height/Width must be no more than 300."

    (check && !checkQuota()) && return "random.org suggests to wait until tomorrow"

    full_path = @sprintf("%s.%s", save, format)
    (isfile(full_path) && overwrite=='n') && return @sprintf("File %s exists. Set overwrite to 'y' to save.", full_path)

    urlbase = "https://www.random.org/bitmaps"
    urltxt = @sprintf("%s?format=%s&height=%d&width=%d&zoom=1",
                        urlbase, format, height, width)
    response = HTTP.get(urltxt)
    if save == ""
        return(response.body)
    else
        # full_path = @sprintf("%s.%s", save, format)
        # if isfile(full_path) && overwrite == 'n'
        #     @printf("File not saved; %s exists. Set overwrite to \"y\".", full_path)
        # else
        open(full_path, "w") do outfile
            write(outfile, response.body)
        end
        @printf("File saved as: %s\n", full_path)
    # end
    end
end

end;  # module
