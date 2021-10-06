---@diagnostic disable: deprecated
-------------------------------------------------------------------------------------------
-- Wojbies API 4.0 - Recursive Table Serialize - Compatible with textutils.unserialize() --
-------------------------------------------------------------------------------------------
--   Copyright (c) 2015-2021 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


--### Initializing
local s = shell and {} or (_ENV or getfenv())
s.versionName = "Recursive Table Serialize By Wojbie"
s.versionNum = 4.0 --2019-12-29

--# Serializes recursive tables into flat textutils.unserialize valid program string.
s.serializeRec = function(t)
    local function serializeFlat(data)
        return string.gsub(textutils.serialize(data), "\n%s*", "")
    end
    if type(t) ~= "table" then
            return serializeFlat(t) --it was not table - do normal serialize
    end
    local tImput = {t}
    local tList = {}
    local tLook = {}
    local tMark = {}
    local tOutp = {"(function() "}
    local cur, nTab
    while #tImput > 0 do
            cur = table.remove(tImput)
            nTab = #tList + 1
            tList[nTab] = cur
            nTab = "t" .. nTab
            tLook[cur] = nTab
            if next(cur) == nil then
                    -- Empty tables are simple
                    tOutp[#tOutp + 1] = nTab .. "={};"
            else
                    --Look over the table, make copy
                    local Basic = {}
                    for k, v in pairs(cur) do
                            if type(k) == "table" or type(v) == "table" then
                                    table.insert(tMark, {cur, k, v})
                                    if type(k) == "table" and not tLook[k] then tImput[#tImput + 1] = k end
                                    if type(v) == "table" and not tLook[v] then tImput[#tImput + 1] = v end
                            else
                                    Basic[k] = v
                            end
                    end
                    tOutp[#tOutp + 1] = nTab .. "=" .. serializeFlat(Basic) .. ";"
            end
    end
    while #tMark > 0 do
            cur = table.remove(tMark)
            tOutp[#tOutp + 1] = tLook[cur[1]] .. "[" .. (type(cur[2]) == "table" and tLook[cur[2]] or serializeFlat(cur[2])) .. "]=" .. (type(cur[3]) == "table" and tLook[cur[3]] or serializeFlat(cur[3])) .. ";"
    end
    tOutp[#tOutp + 1] = "return t1 end)()"
    return table.concat(tOutp)
end

--### Finalizing
return s