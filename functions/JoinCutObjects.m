function Nuclei_new = JoinCutNuclei(Nuclei)

    Nuclei_new=Nuclei;

    Nuc_closed=imclose(Nuclei,strel('disk',1));
    % figure;imshow(Nuc_closed,[]);
    %Nuc_closed=bwlabel(Nuc_closed);
    Nuclei=bwlabel(Nuclei);
    % figure;imshow(Nuclei,[]);

    TheLine=Nuc_closed&~Nuclei; % get only the lines between connecting objects
    % figure;imshow(TheLine,[]);

    TheLine=bwareaopen(TheLine,10); % Remove objects connected with a small amount as they very likely should not be fixed
    % figure;imshow(TheLine,[]);

    PotentialCutCells_closed=imreconstruct(TheLine,Nuc_closed>0);
    PotentialCutCells_closed=bwlabel(PotentialCutCells_closed);
    stats1=regionprops(PotentialCutCells_closed,'solidity');

    PotentialCutCells_open=Nuclei&PotentialCutCells_closed;
    PotentialCutCells_open=bwlabel(PotentialCutCells_open);
    stats2=regionprops(PotentialCutCells_open,'solidity','Area');

    for i=1:length(stats1)
        UniqueList=unique(PotentialCutCells_open(PotentialCutCells_closed==i));
        UniqueList=UniqueList(2:end);
        S1=stats1(i).Solidity;
        for k=1:length(UniqueList)
            S2(k)= stats2(UniqueList(k)).Solidity;
            A2(k)=stats2(UniqueList(k)).Area;
        end
        Score=sum(S2.*A2)/sum(A2);
        improvement_factor = .85; % the improvement to the solidity score has to be by a certain factor for it to count
        % txt = sprintf('Score*improvement_factor>S1: %f = %f * %f > %f', Score*improvement_factor, Score, improvement_factor, S1) % FOR DEBUGGING
        if Score*improvement_factor>S1
            % really 2 cells
        else
            % not two cells
            Nuclei_new(PotentialCutCells_closed==i)=1;
        end
    end
    Nuclei_new=bwlabel(Nuclei_new);
    % figure;imshow(Nuclei_new,[]);


end
