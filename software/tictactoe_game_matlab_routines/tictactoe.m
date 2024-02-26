classdef tictactoe < handle
    %% Class for tictactoe game (Adapted from https://www.mathworks.com/matlabcentral/fileexchange/6179-tic-tac-toe)
    
    properties
        set_nxtnum
        board
        avsq
        sqPlayedSoFar
        player
        otherPlayer
        skill
        set_tr
    end % properties
    
    methods
        
        function thisClass = tictactoe(playerNum,playerSkill)  % Constructor
            if nargin < 2 || nargin > 2
                    error('correct syntax: tictactoe(playerNum,playerSkill)');
            end                        
            thisClass.set_nxtnum = 0;
            thisClass.board = zeros(3,3);
            thisClass.avsq = [1:9];
            thisClass.sqPlayedSoFar = [];
            thisClass.player = playerNum;
            if playerNum==1
                thisClass.otherPlayer = 2;
            elseif playerNum==2
                thisClass.otherPlayer = 1;
            else 
                error('player number can only be 1 or 2');
            end
            if playerSkill==1 || playerSkill==2 || playerSkill==3
                thisClass.skill = playerSkill;
            else 
                error('skill can only be 1 or 2 or 3');
            end
            thisClass.set_tr = 0;
        end
        
        function [squareNum, whichPlayer] = makeYourMove(thisClass, otherPlayerMoveNum)
            
            if otherPlayerMoveNum>0                
                thisClass.board=thisClass.board';
                thisClass.board(otherPlayerMoveNum)=thisClass.otherPlayer;
                thisClass.board=thisClass.board';                
                thisClass.avsq(find(thisClass.avsq==otherPlayerMoveNum))=[];
                thisClass.sqPlayedSoFar = [thisClass.sqPlayedSoFar, otherPlayerMoveNum];
            end
                                    
            b=thisClass.board;
            b=b';
            p = thisClass.player;
            op = thisClass.otherPlayer;
            tr=0;
            num=0;
            nxtnum=0;
            i=1;
            j=thisClass.otherPlayer;
            
            while num==0
                if i==1
                    s=[1 2 3];
                elseif i==2
                    s=[4 5 6];
                elseif i==3
                    s=[7 8 9];
                elseif i==4
                    s=[1 4 7];
                elseif i==5
                    s=[2 5 8];
                elseif i==6
                    s=[3 6 9];
                elseif i==7
                    s=[1 5 9];
                elseif i==8
                    s=[3 5 7];
                elseif i==9
                    num=10;
                end
                
                if b(s(1))==j & b(s(2))==j & b(s(3))==0
                    num=s(3);
                elseif b(s(1))==j & b(s(3))==j & b(s(2))==0
                    num=s(2);
                elseif b(s(2))==j & b(s(3))==j & b(s(1))==0
                    num=s(1);
                end
                i=i+1;
            end
            
            as=length(thisClass.avsq);
            
            if thisClass.skill==1
                a=35;
            elseif thisClass.skill==2
                a=65;
            elseif thisClass.skill==3
                a=100; %95;
            end
            
            if as==9
                prob=ceil(rand*100);
                if prob<=a
                    tr=ceil(rand*3);
                    thisClass.set_tr = tr;
                end
            elseif as==8
                prob=ceil(rand*100);
                if prob<=a
                    tr=4;
                end
            elseif as==7
                tr=thisClass.set_tr;
            elseif as==5 | as==6
                nxtnum=thisClass.set_nxtnum;
                tr=0;
            else
                tr=0;
            end
            
            if num==10
                
                %First Move
                if as==9
                    if tr==1
                        s=[1 3 7 9];
                        num=s(ceil(rand*4));
                    elseif tr==2
                        s=[2 4 6 8];
                        num=s(ceil(rand*4));
                    elseif tr==3
                        num=5;
                    end
                end
                
                %Second Move
                if as==7
                    if tr==1
                        for i=1:4
                            if i==1
                                s=[1 2 4];
                                ss=[1 3 4 7 2];
                                sss=[1 5 6 8];
                                ssss=[1 6 7 8 3];
                                sssss=[1 9 3 7];
                            elseif i==2
                                s=[3 2 6];
                                ss=[3 1 6 9 2];
                                sss=[3 5 4 8];
                                ssss=[3 4 9 8 1];
                                sssss=[3 7 1 9];
                            elseif i==3
                                s=[7 4 8];
                                ss=[7 1 8 9 4];
                                sss=[7 5 2 6];
                                ssss=[7 2 9 6 1];
                                sssss=[7 3 1 9];
                            elseif i==4
                                s=[9 6 8];
                                ss=[9 3 8 7 6];
                                sss=[9 5 2 4];
                                ssss=[9 2 7 4 3];
                                sssss=[9 1 3 7];
                            end
                            if b(s(1))==p & b(s(2))==op
                                num=s(3);
                                nxtnum=5;
                            elseif b(s(1))==p & b(s(3))==op
                                num=s(2);
                                nxtnum=5;
                            elseif b(ss(1))==p & b(ss(2))==op
                                num=ss(3);
                                nxtnum=5;
                            elseif b(ss(1))==p & b(ss(4))==op
                                num=ss(5);
                                nxtnum=5;
                            elseif b(sss(1))==p & b(sss(2))==op
                                num=sss(ceil(rand*2)+2);
                            elseif b(ssss(1))==p & b(ssss(2))==op
                                num=ssss(3);
                                nxtnum=5;
                            elseif b(ssss(1))==p & b(ssss(4))==op
                                num=ssss(5);
                                nxtnum=5;
                            elseif b(sssss(1))==p & b(sssss(2))==op
                                n=ceil(rand*2);
                                if n==1
                                    num=sssss(3);
                                    nxtnum=sssss(4);
                                elseif n==2
                                    num=sssss(4);
                                    nxtnum=sssss(3);
                                end
                            end
                        end
                    elseif tr==2
                        for i=1:4
                            if i==1
                                s=[2 4 1 6 3];
                                ss=[2 7 1 9 3];
                                sss=[2 5 7 9];
                            elseif i==2
                                s=[4 2 1 8 7];
                                ss=[4 3 1 9 7];
                                sss=[4 5 3 9];
                            elseif i==3
                                s=[6 2 3 8 9];
                                ss=[6 1 3 7 9];
                                sss=[6 5 1 7];
                            elseif i==4
                                s=[8 4 7 6 9];
                                ss=[8 1 7 3 9];
                                sss=[8 5 1 3];
                            end
                            if b(s(1))==p & b(s(2))==op
                                num=s(3);
                                nxtnum=5;
                            elseif b(s(1))==p & b(s(4))==op
                                num=s(5);
                                nxtnum=5;
                            elseif b(ss(1))==p & b(ss(2))==op
                                num=ss(3);
                            elseif b(ss(1))==p & b(ss(4))==op
                                num=ss(5);
                            elseif b(sss(1))==p & b(sss(2))==op
                                n=ceil(rand*2);
                                if n==1
                                    num=sss(3);
                                elseif n==2
                                    num=sss(4);
                                end
                            end
                        end
                    elseif tr==3
                        for i=1:4
                            if i==1
                                s=[5 2 4 1 7 6 3 9];
                                ss=[5 1 9 10];
                            elseif i==2
                                s=[5 4 2 1 3 8 7 9];
                                ss=[5 3 7 10];
                            elseif i==3
                                s=[5 8 4 1 7 6 3 9];
                                ss=[5 7 3 10];
                            elseif i==4
                                s=[5 6 2 1 3 8 7 9];
                                ss=[5 9 1 10];
                            end
                            if b(s(1))==p & b(s(2))==op
                                n=ceil(rand*2);
                                nn=ceil(rand*2);
                                if n==1
                                    num=s(3);
                                    if nn==1
                                        nxtnum=s(4);
                                    elseif nn==2
                                        nxtnum=s(5);
                                    end
                                elseif n==2
                                    num=s(6);
                                    if nn==1
                                        nxtnum=s(7);
                                    elseif nn==2
                                        nxtnum=s(8);
                                    end
                                end
                            elseif b(ss(1))==p & b(ss(2))==op
                                num=ss(3);
                                nxtnum=ss(4);
                            end
                        end
                    end
                end
                
                %Third Move
                if as==5 & nxtnum~=0
                    if nxtnum==10
                        if b(2)==op & b(1)==p
                            num=7;
                        elseif b(2)==op & b(3)==p
                            num=9;
                        elseif b(4)==op & b(1)==p
                            num=3;
                        elseif b(4)==op & b(7)==p
                            num=9;
                        elseif b(6)==op & b(3)==p
                            num=1;
                        elseif b(6)==op & b(9)==p
                            num=7;
                        elseif b(8)==op & b(7)==p
                            num=1;
                        elseif b(8)==op & b(9)==p
                            num=3;
                        end
                    else
                        num=nxtnum;
                    end
                end
                
                %Blocks
                if tr==4
                    for i=1:4
                        if i==1
                            s=[1 5];
                            ss=[2 1 3 5];
                        elseif i==2
                            s=[3 5];
                            ss=[4 1 5 7];
                        elseif i==3
                            s=[7 5];
                            ss=[6 3 5 9];
                        elseif i==4
                            s=[9 5];
                            ss=[8 5 7 9];
                        end
                        if b(s(1))==op
                            num=s(2);
                            nxtnum=10;
                        elseif b(ss(1))==op
                            n=ceil(rand*3)+1;
                            num=ss(n);
                            nxtnum=10;
                        elseif b(5)==op
                            sss=[1 3 7 9];
                            n=ceil(rand*4);
                            num=sss(n);
                            nxtnum=10;
                        end
                    end
                end
                
                %Block 2
                if as==6 & nxtnum==10
                    for i=1:4
                        if i==1
                            s=[1 9 5];
                            ss=[1 5 9 3 7];
                            sss=[2 1 3 5];
                            ssss=[2 5 4 1 6 3];
                            sssss=[1 5 8 7 6 3];
                        elseif i==2
                            s=[1 9 5];
                            ss=[3 5 7 1 9];
                            sss=[4 1 7 5];
                            ssss=[4 5 2 1 8 7];
                            sssss=[3 5 8 9 4 1];
                        elseif i==3
                            s=[3 7 5];
                            ss=[7 5 3 1 9];
                            sss=[6 3 9 5];
                            ssss=[6 5 2 3 8 9];
                            sssss=[7 5 2 1 6 9];
                        elseif i==4
                            s=[3 7 5];
                            ss=[9 5 1 3 7];
                            sss=[8 7 9 5];
                            ssss=[8 5 4 7 6 9];
                            sssss=[9 5 2 3 4 7];
                        end
                        if b(s(1))==op & b(s(2))==op & b(s(3))==p
                            sp=[2 4 6 8];
                            num=sp(ceil(rand*4));
                        elseif b(ss(1))==p & b(ss(2))==op & b(ss(3))==op
                            n=ceil(rand*2)+3;
                            num=ss(n);
                        elseif b(sss(1))==op & (b(sss(2))==p | b(sss(3))==p) & b(5)==0
                            num=5;
                        elseif b(ssss(1))==op & b(ssss(2))==p & b(ssss(3))==op
                            num=ssss(4);
                        elseif b(ssss(1))==op & b(ssss(2))==p & b(ssss(5))==op
                            num=ssss(6);
                        elseif b(sssss(1))==op & b(sssss(2))==p & b(sssss(3))==op
                            num=sssss(4);
                        elseif b(sssss(1))==op & b(sssss(2))==p & b(sssss(4))==op
                            num=sssss(5);
                        end
                    end
                end
                
                %Other Move
                if num==10
                    num=thisClass.avsq(ceil(length(thisClass.avsq)*rand));
                end
                
            end
            
            thisClass.set_nxtnum = nxtnum;
            thisClass.avsq(find(thisClass.avsq==num))=[];
            thisClass.sqPlayedSoFar = [thisClass.sqPlayedSoFar, num];
            
            thisClass.board=thisClass.board';
            thisClass.board(num)=thisClass.player;
            thisClass.board=thisClass.board';
            
            squareNum = num;
            whichPlayer = thisClass.player;
            
            thisClass.board
                        
        end
        
        function [whoWon,WinningSquares] = checkForWin(thisClass)

            b=thisClass.board;
            b=b';
            whoWon=0;
            WinningSquares=[0 0 0];
            
            for i=1:2
                if b(1)==i & b(2)==i & b(3)==i
                    whoWon=i;
                    WinningSquares=[1 2 3];
                elseif b(4)==i & b(5)==i & b(6)==i
                    whoWon=i;
                    WinningSquares=[4 5 6];
                elseif b(7)==i & b(8)==i & b(9)==i
                    whoWon=i;
                    WinningSquares=[7 8 9];
                elseif b(1)==i & b(4)==i & b(7)==i
                    whoWon=i;
                    WinningSquares=[1 4 7];
                elseif b(2)==i & b(5)==i & b(8)==i
                    whoWon=i;
                    WinningSquares=[2 5 8];
                elseif b(3)==i & b(6)==i & b(9)==i
                    whoWon=i;
                    WinningSquares=[3 6 9];
                elseif b(1)==i & b(5)==i & b(9)==i
                    whoWon=i;
                    WinningSquares=[1 5 9];
                elseif b(3)==i & b(5)==i & b(7)==i
                    whoWon=i;
                    WinningSquares=[3 5 7];
                end
            end
        end
        
    end
    
end