classdef VoiceChanger < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        FiltersLabel          matlab.ui.control.Label
        EffectsLabel          matlab.ui.control.Label
        MeasuresLabel         matlab.ui.control.Label
        SaveCheckBox          matlab.ui.control.CheckBox
        SemitonesSlider       matlab.ui.control.Slider
        SemitonesSliderLabel  matlab.ui.control.Label
        VolumeSlider          matlab.ui.control.Slider
        VolumeSliderLabel     matlab.ui.control.Label
        SpeedSlider           matlab.ui.control.Slider
        SpeedSliderLabel      matlab.ui.control.Label
        Switch                matlab.ui.control.Switch
        PlayButton            matlab.ui.control.Button
        SaveButton            matlab.ui.control.Button
        BandpassFilterButton  matlab.ui.control.Button
        StopbandFilterButton  matlab.ui.control.Button
        NoiseFilterButton     matlab.ui.control.Button
        EchoButton            matlab.ui.control.Button
        VolumeButton          matlab.ui.control.Button
        ChipmunkButton        matlab.ui.control.Button
        SpeedButton           matlab.ui.control.Button
        ReverseButton         matlab.ui.control.Button
        PitchButton           matlab.ui.control.Button
        StopRecordingButton   matlab.ui.control.Button
        RecordButton          matlab.ui.control.Button
        UIAxes2               matlab.ui.control.UIAxes
        UIAxes_2              matlab.ui.control.UIAxes
        UIAxes                matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RecordButton
        function RecordButtonPushed(app, event)
            global Recorder
            global counter
            
            Recorder = audiorecorder;

            disp('Recording');

            record(Recorder);

            counter = 0;        
        end

        % Button pushed function: StopRecordingButton
        function StopRecordingButtonPushed(app, event)
            global Recorder
            stop(Recorder);
            disp('Recording has stop');
            Fs = Recorder.SampleRate
            x = getaudiodata(Recorder);
            
            tsignal= [0:length(x)-1]/Fs
            plot(app.UIAxes,tsignal,x);
        end

        % Button pushed function: PitchButton
        function PitchButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end

            nsemitones = app.SemitonesSlider.Value;
            lockPhase = false;
            Fs = Recorder.SampleRate;
            
            y = shiftPitch(x,nsemitones,'LockPhase',lockPhase);
            sound(y,Fs);

            tsignal= [0:length(y)-1]/Fs
            plot(app.UIAxes_2,tsignal,y);

            if app.SaveCheckBox.Value == 1

                output_x = y;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: SpeedButton
        function SpeedButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter
            
            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end
            
            multiplier = app.SpeedSlider.Value;
            
            y = Fs * multiplier;
            sound(x,y);
           
%             y = stretchAudio(x,multiplier);
%             sound (y);            
%                    
            tsignal= [0:length(x)-1]/y
            plot(app.UIAxes_2,tsignal,x);
            
            

            if app.SaveCheckBox.Value == 1

                output_x = x;
                output_Fs = y;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: VolumeButton
        function VolumeButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter
            
            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end

            y = x * app.VolumeSlider.Value;
            sound(y,Fs);
            
            tsignal= [0:length(y)-1]/Fs
            plot(app.UIAxes_2,tsignal,y);
            %plot(app.UIAxes_2,y);
            
            if app.SaveCheckBox.Value == 1

                output_x = y;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: EchoButton
        function EchoButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end

            delay=0.5;
            amp=0.5;
            ds = round((delay)*Fs);    %%CALCULATING DELAY SAMPLE NUMBERS
            if ds==0                   %%THIS APPENDS TO THE INPUT TO EQUAL THE SIZE WITH OUTPUT
                append=[];             %%APPENDS EMPTY MATRIX WHILE 'ds' IS ZERO
            else
                append=zeros(ds,1);    %%APPENDS ZERO VECTOR FOR THE DELAY
            end
            ain = [append;x];       %%APPENDED INPUT
            dmwa = amp*ain;             %%AMPLIFIED SIGNAL
            outd = [x; append];     %%APPENDED OUTPUT
            out = (dmwa+outd);          %%OUTPUT WITHOUT SCALLING
                
            %%% SCALLING (IF NEEDED)   
            mx = max(out);
            mn = min(out);
            if max(abs(out))>1
                if(abs(mx)>abs(mn))
                    output = out/abs(mx);
                else
                    output = out/abs(mn);
                end
            else
                 output=out;            %%OUTPUT WITH SCALLING(IF NEEDED)
            end
            
            sound(output,Fs);

            tsignal= [0:length(output)-1]/Fs
            plot(app.UIAxes_2,tsignal,output);
            %plot(app.UIAxes_2,output);
            
            if app.SaveCheckBox.Value == 1

                output_x = output;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: ReverseButton
        function ReverseButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end

            [m,n]=size(x);
            if n==1 % If y is not row vector this convert it into row vector.
                x=x'; 
            end
            x1=fliplr(x); % Now flip it and check audio.
            
            sound(x1,Fs); % Now, lest listen to your reverse audio.

            tsignal= [0:length(x1)-1]/Fs
            plot(app.UIAxes_2,tsignal,x1);
            plot(app.UIAxes_2,x1);

            if app.SaveCheckBox.Value == 1

                output_x = x1;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: ChipmunkButton
        function ChipmunkButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                %[output_x,output_Fs] = audioread('appoutputtest.wav')
                
                x = output_x
                Fs = output_Fs
            end
            %y = getaudiodata(Recorder);
            
            nsemitones=4;
            lockPhase= true;
            audioOut = shiftPitch(x,nsemitones,"LockPhase",lockPhase);

            sound(audioOut,Fs);

            tsignal= [0:length(audioOut)-1]/Fs
            plot(app.UIAxes_2,tsignal,audioOut);
            %plot(app.UIAxes_2,audioOut);
            

            if app.SaveCheckBox.Value == 1

                output_x = audioOut;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: NoiseFilterButton
        function NoiseFilterButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end

            
            %signal = getaudiodata(Recorder);
            Ts=1/Fs;
            timeVector = (0:Ts:length(x)*Ts - Ts);
            
            %first order low pass filter
            filtHz =500;
            filtnum = [2*pi*filtHz];
            filtden =[  1 1*pi*filtHz];
            [filtnumd,filtdend] = c2dm(filtnum,filtden,1/Fs,'zoh');

            %filter signal with first order low pass filter
            Filtered = filter(filtnumd,filtdend,x);

            sound(Filtered,Fs);

            tsignal= [0:length(Filtered)-1]/Fs
            plot(app.UIAxes_2,tsignal,Filtered);
          %  plot(app.UIAxes_2,Filtered);

            if app.SaveCheckBox.Value == 1

                output_x = Filtered;
                output_Fs = Fs;
                counter = counter+1

                app.SaveCheckBox.Value = false;
            end
        end

        % Button pushed function: StopbandFilterButton
        function StopbandFilterButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end
            
           
            N = length(x);
            % N = number of samples
            % Now generate a general plot of the frequency spectrum
            f = Fs/N.*(0:N-1);
            % calculate each frequency component
            YY = fft(x,N);
            Y = abs(YY(1:N))./(N/2);
            
            %fNq = Fs/2; 
            Wn = [1000 3000]/(Fs/2);
            [b,a]=butter(6,Wn,'stop');
            filterBand_stop=filtfilt(b,a,x);
            

            tsignal= [0:length(filterBand_stop)-1]/Fs
            plot(app.UIAxes_2,tsignal,filterBand_stop);

            % calculate each frequency component for the altered file
            YY=fft(filterBand_stop,N);
            Y1=abs(YY(1:N))./(N/2);
            plot(app.UIAxes2,f,20*log(Y1))

            sound (filterBand_stop,Fs)
            %  


        end

        % Button pushed function: BandpassFilterButton
        function BandpassFilterButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter

            if counter == 0 
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
            else
                x = output_x
                Fs = output_Fs
            end
            
            %%%    [y, Fs]=audioread('input.wav'); 

            N=length(x);
            % N = number of samples
            % Now generate a general plot of the frequency spectrum
            f=Fs/N.*(0:N-1);
            % calculate each frequency component
            YY=fft(x,N);
            Y=abs(YY(1:N))./(N/2);

            %fNq = Fs/2; 
            Wn = [1000 3000]/(Fs/2);
            [b,a]=butter(6,Wn);
            filterBand_pass=filtfilt(b,a,x);

            tsignal= [0:length(filterBand_pass)-1]/Fs
            plot(app.UIAxes_2,tsignal,filterBand_pass);
            
            % calculate each frequency component for the altered file
            YY=fft(filterBand_pass,N);
            Y1=abs(YY(1:N))./(N/2);
           
            plot(app.UIAxes2,f,20*log(Y1))
   
            %do playback
            %soundsc(filterBand_pass);
            sound(filterBand_pass,Fs)
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs
            global counter
            

         %   audiowrite('appoutputtest.wav',output_x,output_Fs);

            if counter == 0
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
                audiowrite('appinputtest.wav',x,Fs);
            else
                audiowrite('appoutputtest.wav',output_x,output_Fs);
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            global Recorder
            global output_x
            global output_Fs

           

            %s = comp.Switch.Value

            if app.Switch.Value == 0
                x = getaudiodata(Recorder);
                Fs = Recorder.SampleRate;
                sound(x,Fs);
             else 
                 
                 sound(output_x,output_Fs);
                 
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1166 638];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Input')
            xlabel(app.UIAxes, 'Time (sec)')
            ylabel(app.UIAxes, 'Amplitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [514 329 570 290];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Processed')
            xlabel(app.UIAxes_2, 'Time (sec)')
            ylabel(app.UIAxes_2, 'Amplitude')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Position = [511 29 570 290];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Band Stop/Pass')
            xlabel(app.UIAxes2, 'Frequency(Hz)')
            ylabel(app.UIAxes2, 'PSD')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [300 38 190 150];

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.Position = [81 596 100 23];
            app.RecordButton.Text = 'Record';

            % Create StopRecordingButton
            app.StopRecordingButton = uibutton(app.UIFigure, 'push');
            app.StopRecordingButton.ButtonPushedFcn = createCallbackFcn(app, @StopRecordingButtonPushed, true);
            app.StopRecordingButton.Position = [211 596 100 23];
            app.StopRecordingButton.Text = 'Stop Recording';

            % Create PitchButton
            app.PitchButton = uibutton(app.UIFigure, 'push');
            app.PitchButton.ButtonPushedFcn = createCallbackFcn(app, @PitchButtonPushed, true);
            app.PitchButton.Position = [30 516 100 23];
            app.PitchButton.Text = 'Pitch';

            % Create ReverseButton
            app.ReverseButton = uibutton(app.UIFigure, 'push');
            app.ReverseButton.ButtonPushedFcn = createCallbackFcn(app, @ReverseButtonPushed, true);
            app.ReverseButton.Position = [160 516 100 23];
            app.ReverseButton.Text = 'Reverse';

            % Create SpeedButton
            app.SpeedButton = uibutton(app.UIFigure, 'push');
            app.SpeedButton.ButtonPushedFcn = createCallbackFcn(app, @SpeedButtonPushed, true);
            app.SpeedButton.Position = [30 476 100 23];
            app.SpeedButton.Text = 'Speed';

            % Create ChipmunkButton
            app.ChipmunkButton = uibutton(app.UIFigure, 'push');
            app.ChipmunkButton.ButtonPushedFcn = createCallbackFcn(app, @ChipmunkButtonPushed, true);
            app.ChipmunkButton.Position = [160 476 100 23];
            app.ChipmunkButton.Text = 'Chipmunk';

            % Create VolumeButton
            app.VolumeButton = uibutton(app.UIFigure, 'push');
            app.VolumeButton.ButtonPushedFcn = createCallbackFcn(app, @VolumeButtonPushed, true);
            app.VolumeButton.Position = [30 436 100 23];
            app.VolumeButton.Text = 'Volume';

            % Create EchoButton
            app.EchoButton = uibutton(app.UIFigure, 'push');
            app.EchoButton.ButtonPushedFcn = createCallbackFcn(app, @EchoButtonPushed, true);
            app.EchoButton.Position = [160 436 100 23];
            app.EchoButton.Text = 'Echo';

            % Create NoiseFilterButton
            app.NoiseFilterButton = uibutton(app.UIFigure, 'push');
            app.NoiseFilterButton.ButtonPushedFcn = createCallbackFcn(app, @NoiseFilterButtonPushed, true);
            app.NoiseFilterButton.Position = [291 516 100 23];
            app.NoiseFilterButton.Text = 'Noise Filter';

            % Create StopbandFilterButton
            app.StopbandFilterButton = uibutton(app.UIFigure, 'push');
            app.StopbandFilterButton.ButtonPushedFcn = createCallbackFcn(app, @StopbandFilterButtonPushed, true);
            app.StopbandFilterButton.Position = [291 436 100 23];
            app.StopbandFilterButton.Text = 'Stopband Filter';

            % Create BandpassFilterButton
            app.BandpassFilterButton = uibutton(app.UIFigure, 'push');
            app.BandpassFilterButton.ButtonPushedFcn = createCallbackFcn(app, @BandpassFilterButtonPushed, true);
            app.BandpassFilterButton.Position = [291 476 100 23];
            app.BandpassFilterButton.Text = 'Bandpass Filter';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [161 336 100 23];
            app.SaveButton.Text = 'Save';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [31 336 100 23];
            app.PlayButton.Text = 'Play';

            % Create Switch
            app.Switch = uiswitch(app.UIFigure, 'slider');
            app.Switch.Items = {'Input', 'Processed'};
            app.Switch.ItemsData = [0 1];
            app.Switch.Position = [42 375 53 24];
            app.Switch.Value = 0;

            % Create SpeedSliderLabel
            app.SpeedSliderLabel = uilabel(app.UIFigure);
            app.SpeedSliderLabel.HorizontalAlignment = 'right';
            app.SpeedSliderLabel.Position = [35 267 40 22];
            app.SpeedSliderLabel.Text = 'Speed';

            % Create SpeedSlider
            app.SpeedSlider = uislider(app.UIFigure);
            app.SpeedSlider.Limits = [0.5 2.5];
            app.SpeedSlider.MajorTicks = [0.5 1 1.5 2 2.5];
            app.SpeedSlider.Position = [96 276 182 3];
            app.SpeedSlider.Value = 1;

            % Create VolumeSliderLabel
            app.VolumeSliderLabel = uilabel(app.UIFigure);
            app.VolumeSliderLabel.HorizontalAlignment = 'right';
            app.VolumeSliderLabel.Position = [34 197 46 22];
            app.VolumeSliderLabel.Text = 'Volume';

            % Create VolumeSlider
            app.VolumeSlider = uislider(app.UIFigure);
            app.VolumeSlider.Limits = [0 5];
            app.VolumeSlider.Position = [101 206 180 3];
            app.VolumeSlider.Value = 1;

            % Create SemitonesSliderLabel
            app.SemitonesSliderLabel = uilabel(app.UIFigure);
            app.SemitonesSliderLabel.HorizontalAlignment = 'right';
            app.SemitonesSliderLabel.Position = [31 127 62 22];
            app.SemitonesSliderLabel.Text = 'Semitones';

            % Create SemitonesSlider
            app.SemitonesSlider = uislider(app.UIFigure);
            app.SemitonesSlider.Limits = [-10 10];
            app.SemitonesSlider.Position = [111 136 170 3];

            % Create SaveCheckBox
            app.SaveCheckBox = uicheckbox(app.UIFigure);
            app.SaveCheckBox.Text = 'Save';
            app.SaveCheckBox.Position = [291 337 50 22];

            % Create MeasuresLabel
            app.MeasuresLabel = uilabel(app.UIFigure);
            app.MeasuresLabel.FontSize = 15;
            app.MeasuresLabel.FontWeight = 'bold';
            app.MeasuresLabel.Position = [41 557 74 22];
            app.MeasuresLabel.Text = 'Measures';

            % Create EffectsLabel
            app.EffectsLabel = uilabel(app.UIFigure);
            app.EffectsLabel.FontSize = 15;
            app.EffectsLabel.FontWeight = 'bold';
            app.EffectsLabel.Position = [171 557 56 22];
            app.EffectsLabel.Text = 'Effects';

            % Create FiltersLabel
            app.FiltersLabel = uilabel(app.UIFigure);
            app.FiltersLabel.FontSize = 15;
            app.FiltersLabel.FontWeight = 'bold';
            app.FiltersLabel.Position = [301 557 50 22];
            app.FiltersLabel.Text = 'Filters';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VoiceChanger

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end