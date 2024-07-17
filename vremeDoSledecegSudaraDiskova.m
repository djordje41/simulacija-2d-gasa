% Vraca vreme do sudara sledeca dva diska u zadatom nizu diskova, kao i
% indekse oba diska u nizu.
function [vreme, index1, index2] = vremeDoSledecegSudaraDiskova(diskovi)
    vreme = inf;
            
    [~, brojDiskova] = size(diskovi);

    index1 = -1;
    index2 = -1;

    for i = 1 : brojDiskova - 1
        for j = i + 1 : brojDiskova
            vremeDoSudara = diskovi(i).vremeDoSudara(diskovi(j));

            if ((vremeDoSudara ~= -1) && (vremeDoSudara < vreme))
                vreme = vremeDoSudara;

                index1 = i;
                index2 = j;
            end
        end
    end

    if (vreme == inf)
        vreme = -1; 
    end
end