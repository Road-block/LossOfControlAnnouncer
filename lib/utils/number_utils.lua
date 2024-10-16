-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.utils = ns.utils or {}

--local _INF = 1 / 0
--local _INF_TOSTRING = tostring(_INF)
--local _NAN = math.abs(0 / 0)
--local _NAN_TOSTRING = tostring(_NAN)

function ns.utils.is_infinite(n)
  return type(n)=="number" and (abs(n) == math.huge)
end

function ns.utils.is_nan(n)
  return type(n)=="number" and n ~= n
end

function ns.utils.is_finite(n)
  return not ns.utils.is_infinite(n) and
      not ns.utils.is_nan(n)
end

function ns.utils.is_integer(n)
  return n == math.floor(n) and ns.utils.is_finite(n)
end
