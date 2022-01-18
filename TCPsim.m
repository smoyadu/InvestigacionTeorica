function varargout = TCPsim(varargin)
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TCPsim_OpeningFcn, ...
                   'gui_OutputFcn',  @TCPsim_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function TCPsim_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = TCPsim_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



function dmin_Callback(hObject, eventdata, handles)                        % Minimum dose per fraction 
    global dmin 
    dmin=str2double(get(hObject,'String')); 
    
function dmin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Alfa_Callback(hObject, eventdata, handles)                        % Alfa LQ S(d) parameter 
    global Alfa 
    Alfa=str2double(get(hObject,'String')); 
    
function Alfa_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AlfaBeta_Callback(hObject, eventdata, handles)                    % AlfaBeta LQ S(d) parameters 
    global AlfaBeta 
    AlfaBeta=str2double(get(hObject,'String')); 
    
function AlfaBeta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SL1_Callback(hObject, eventdata, handles)                         % Probability of cell sub-lethally damage 
    global SL1 
    SL1=str2double(get(hObject,'String'))*(10/100);     

   
function SL1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CR_Callback(hObject, eventdata, handles)                          % Probability of cell repair of the interfraction for the SL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global CR 
    CR=str2double(get(hObject,'String'))*(10/100);     

   
function CR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Vol_Callback(hObject, eventdata, handles)                         % Volume of region with minimun dose in mm3. It sugeested 1 mm3
    global Vol 
    Vol=str2double(get(hObject,'String'))*1e-03;                           % For converting mm3 to cm3                      
    
function Vol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Cden_Callback(hObject, eventdata, handles)                        % Cell density 
    global Cden 
    Cden=str2double(get(hObject,'String'))*1e07;  
    
function Cden_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%% For virtual simualtions  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nvs_Callback(hObject, eventdata, handles)                         % Number of virtual simulations   
    global nvs 
    nvs=str2double(get(hObject,'String'));
    
function nvs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function n_Callback(hObject, eventdata, handles)                           % Number of the fractions for n
    global n 
    n=str2double(get(hObject,'String')); 
    
function n_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 %%%%%%%%%%%%%%%% Function %%%%%%%%%%%%%%%%%%%%

function Calculate_Callback(hObject, eventdata, handles)                   % Function Calculculate for the "TCPsim" module

    global nvs Cden Vol n SL1 CR dmin Alfa AlfaBeta 
    S1=exp(-(Alfa*dmin+(Alfa/AlfaBeta)*dmin^2));                           % The linear quadratic cell survival, the LQ S(dmin)                               
    K1=1-S1;                                                               % Cell kill (K) is probabilistically 1-Cell survival S, K1= 1- LQ S(d)
    NTC=Cden*Vol;                                                          % Number total of cells in Vol 
    TC=0;                                                                  % Tumor control
    ci=clock;                                                              % Starting time of execution
    for i=1:nvs 
        nkc=NTC*K1;                                                        % Number of killed cells of the 1st fraction 
        nslc1=NTC*SL1;                                                     % Number of sub-lethally damaged (SL)cells just after the 1st fraction
        nrc=nslc1*CR;                                                      % Number of repaired cells after the 1st fraction
        nslcj=nslc1-nrc;                                                   % Number of SL cells after the 1st fraction
        nudc=NTC-(nkc+nslc1)+nrc;                                          % Number of undamaged (UD)cells  + Repaired SL cells after of the 1st fraction
        for j=2:n 
            for k=1:round(NTC)                                             % Integer number of cells in Vol
                gnum=rand;
                if gnum>(nkc/NTC)                                          % For meeting one survived cell
                    gnum=rand;
                    if gnum>(nslcj/(nslcj+nudc))                           % For meeting one UD cell                                            
                        gnum=rand;
                        if gnum<K1                                         % For killing one UD cell
                            nkc=nkc+1;                                     % One UD cell was killed
                        elseif (gnum>=K1) && (gnum <K1+SL1)                % For transforming one UD cell to SL cell                            
                            nslcj=nslcj+1;
                        else
                             continue
                        end 
                    else                                                   
                       gnum1=rand;                                         %%%%%%%%%%%%%%%%%% For defining range of sub-lathal damage 
                       KSL=max(gnum1,1-gnum1);                             %%%%%%%%%%%%%%%%%%
                       gnum2=rand;                                         %%%%%%%%%%%%%%%%%%% 
                        if (gnum2<KSL)                                     %%%%%%%%%%%%%%%  % For a major probability of killing the SL cell    
                            nkc=nkc+1;
                            nslcj=nslcj-1;                                 % One SL cell was killed
                        end    
                    end 
                else
                    continue 
                end
                nudc=NTC-(nkc+nslcj);
            end 
            
             %%%%%%%%%%% Cell repair process %%%%%%%%%%%%%%%%%%%%%
            
            nrc=nslcj*CR;                                                  % Number of repaired cells after jth fraction 
            nslcj=nslcj-nrc;                                               % Number of SL cells after the jth fraction
            nudc=NTC-(nkc+nslcj)+nrc;                                      % Number of undamaged (UD)cells  + Repaired SL cells after of the 1st fraction 
                     
        end
        if nkc >= NTC
            TC=TC+1;    
        end    
    end  
    TCP=TC ./nvs;                                                            % Probabilistic definition of the TCP 
    
    set(handles.S1text,'String',[num2str(S1*100,2),' %']);
    set(handles.TCP,'String',[num2str(single(TCP*100),3),' %']);
    cf=clock;                                                              % Final time of execution 
    set(handles.t,'String',[num2str(ci(4)),':',num2str(ci(5)),' / ',num2str(cf(4)),':',num2str(cf(5))]);
    
  








