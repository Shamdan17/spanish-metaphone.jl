# Initial replacements to perform
replacements = Dict("á"=>"A","ch"=>"X","ç"=>"S","é"=>"E","í"=>"I","ó"=>"O","ú"=>"U","ñ"=>"NY","gü"=>"W","ü"=>"U","b"=>"V","ll"=>"Y")

# Vowels
vowels = Set(['A', 'E', 'I', 'O', 'U'])

# Consonants that make a single sound
single_sound_consonants = Set(['D','F','J','K','M','N','P','T','V','L','Y'])

function is_vowel(c::Char)
    in(c, vowels)
end

# Replace some easily confused spanish characters
function fixstr(st::AbstractString)
    for replacement in replacements
        st = replace(st, replacement)
    end
    st
end

"""
    metaphone(s::AbstractString, key_length=6)

Calculate the metaphone of a Spanish string `s` upto a given length `key_length`. Default `key_length` is 6.

# Examples
```jldoctest
julia> metaphone("consideración")
"KNSDRZ"

julia> metaphone("consideración", 7)
"KNSDRZN"

julia> metaphone("consideración", 8)
"KNSDRZN"

julia> metaphone("consideración", 2)
"KN"
```
"""
function metaphone(s::AbstractString, key_length=6)
    # initialize metaphone key string    
    meta_key = ""
    # String length
    n = length(s)
    # Pointer to current character
    current_pos = 1
    #Set to the end of the string
    original_string = s* "    "
    # Replace some easily confused spanish characters
    original_string = uppercase(fixstr(lowercase(original_string)))

    # main loop
    while length(meta_key)<key_length
        #break out of the loop if greater or equal than the length
        if current_pos > length(original_string)
            break
        end
        #get character from the string
        current_char = original_string[current_pos]
#         @show current_char
#         @show current_pos
#         @show original_string
        if is_vowel(current_char) && current_pos==1
            meta_key *= current_char
            current_pos = nextind(original_string, current_pos)
        else
            #Let's check for consonants  that have a single sound 
            #or already have been replaced  because they share the same
            #sound like 'B' for 'V' and 'S' for 'Z'
            if in(current_char, single_sound_consonants)
                meta_key *= current_char
                current_pos = nextind(original_string, current_pos)
                
                #increment by two if a repeated letter is found
                if original_string[current_pos] == current_char
                    current_pos = nextind(original_string, current_pos)
                end
            else #check consonants with similar confusing sounds 
                if current_char == 'C'
                    #special case 'macho', chato,etc.  
                    #if original_string[nextind(original_string, current_pos)]=='H'
                    #    current_pos = nextind(original_string, current_pos, 2) 
                    
                    #special case 'acción', 'reacción',etc.
                    if original_string[nextind(original_string, current_pos)] == 'C'
                        meta_key*= 'X'
                        current_pos = nextind(original_string, current_pos, 2) 
                    # special case 'cesar', 'cien', 'cid', 'conciencia'
                    elseif in(original_string[nextind(original_string, current_pos)], ['E','I'])
                        meta_key *= 'Z'
                        current_pos = nextind(original_string, current_pos, 2) 
                    else
                        meta_key *= 'K'
                        current_pos = nextind(original_string, current_pos)
                    end
                elseif current_char == 'G'
                    # special case 'gente', 'ecologia',etc 
                    if in(original_string[nextind(original_string, current_pos)], ['E','I'])
                        meta_key *= 'J'
                        current_pos = nextind(original_string, current_pos, 2) 
                    else
                        meta_key *= 'G'
                        current_pos = nextind(original_string, current_pos)
                    end
                #since the letter 'h' is silent in spanish, 
                #let's set the meta key to the vowel after the letter 'h'
                elseif current_char == 'H'
                    if is_vowel(original_string[nextind(original_string, current_pos)])
                        meta_key *= original_string[nextind(original_string, current_pos)]
                        current_pos = nextind(original_string, current_pos, 2) 
                    else
                        meta_key *= 'H'
                        current_pos = nextind(original_string, current_pos)
                    end
                elseif current_char == 'Q'
                    if original_string[nextind(original_string, current_pos)]=='U'
                        current_pos = nextind(original_string, current_pos, 2) 
                    else
                        meta_key *= 'K'
                        current_pos = nextind(original_string, current_pos)
                    end
                elseif current_char == 'W'
                    meta_key *= 'U'
                    current_pos = nextind(original_string, current_pos)
                
                # perro, arrebato, cara
                elseif current_char == 'R'
                    meta_key *= 'R'
                    current_pos = nextind(original_string, current_pos) 
                # spain
                elseif current_char == 'S'
                    if !is_vowel(original_string[nextind(original_string, current_pos)]) && current_pos == 1
                        meta_key *= "ES"
                        current_pos = nextind(original_string, current_pos)
                    else
                        meta_key *= 'S'
                        current_pos = nextind(original_string, current_pos)
                    end
                # zapato
                elseif current_char == 'Z'
                    meta_key *= 'Z'
                    current_pos = nextind(original_string, current_pos)
                elseif current_char == 'X'
                    if !is_vowel(original_string[nextind(original_string, current_pos)]) && n>1 && current_pos == 1
                        meta_key *= "EX"
                        current_pos = nextind(original_string, current_pos)
                    else
                        meta_key *= 'X'
                        current_pos = nextind(original_string, current_pos)
                    end
                else
                    current_pos = nextind(original_string, current_pos)
                end
            end
        end
    end 
    strip(meta_key)
end