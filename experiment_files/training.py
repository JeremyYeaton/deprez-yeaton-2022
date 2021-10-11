#!/usr/bin/env python

#-------------------------------------------------------------------------------
# Name:        Experiment N-2014
# Version:     1.1
# Author:      Luca Iacoponi - jacoponi@gmail.com
# Created:     12 Dec 2014
#-------------------------------------------------------------------------------

""" Run an experiment where the subjects read a sentence
and their responses are recorded.
"""

import os
import random
import time
import pygame
import codecs
import pyaudio
import wave
import sys
from datetime import datetime
import csv

class eSound(pygame.mixer.Sound):
    def __init__(self, filename, name):
        super(eSound, self).__init__(filename)
        self.name = name

class PsExperiment:
    def __init__(self, info):
        """ Experiment class for PsychoPy """
        # Store info about the experiment
        self.info = info

        # setup logifle
        self.stim_dir = os.path.join('log', info['sujet'])
        if not os.path.exists(self.stim_dir):
            print 'Creating dir: ' + self.stim_dir
            os.makedirs(self.stim_dir)
        stim_file = os.path.join(self.stim_dir, 'stimuli_trial.csv')
        try:
            self.stim_file = open(stim_file, 'w')
            print stim_file
        except Exception, e:
            print 'Spiacente, impossibile scrivere il file: ' + stim_file
            sys.exit(1)
        self.stim_file.writelines("ID\tContext\tStimulus\tTruth Value\tRT\n")

        # Set recording variables
        self.chunk = 1024
        self.FORMAT = pyaudio.paInt16
        self.CHANNELS = 1
        self.RATE = 44100
        self.RECORD_SECONDS =60

        self.white = (255,255,255)
        self.black = (0,0,0)
        self.red = (255, 0, 0)

        self.stimuli = []
        # Setup Window
        # Define some
        pygame.init()
        self.silver = (192, 192, 192)
        # Set the height and width of the screen
        size = [700,500]
        self.screen = pygame.display.set_mode(size, pygame.FULLSCREEN)
        self.myfont = pygame.font.SysFont('Arial', 20)
        pygame.display.set_caption('Negation experiment - ' + info['sujet'])
        # Initialise sounds
        # Misc sounds
        self.beep = eSound(os.path.join('misc', 'beep.wav'), 'beep')
        # loadstimuli
        critical1 = []
        critical2 = []
        critical3 = []
        critical4 = []
        control = []
        filler = []
        crit1num = 2
        crit2num = 0
        crit3num = 0
        crit4num = 0
        # in each block there are 4 crits, 3 fill, 1 contr.
        # there are 8 blocks, and so 7*8 = 64 stimuli
        contnum = 0
        fillnum = 0
        blocknum = 1
        with open(os.path.join('misc', 'trial.txt')) as tsv:
            for line in csv.reader(tsv, dialect="excel-tab"):
                if line[0][0] == "#":
                    pass
                elif line[0].startswith("Critical1"):
                   critical1.append(line)
                elif line[0].startswith("Critical2"):
                   critical2.append(line)
                elif line[0].startswith("Critical3"):
                   critical3.append(line)
                elif line[0].startswith("Critical4"):
                   critical4.append(line)
                elif line[0].startswith("Control"):
                   control.append(line)
                elif line[0].startswith("Filler"):
                   filler.append(line)
        print len(critical1), len(critical2), len(critical3), len(critical4), len(control), len(filler)
        # 1 blocks
        for i in range(0, blocknum):
            block = []
            stim = []
            block.append(critical1.pop(random.randint(0, len(critical1) - 1)))
            block.append(critical1.pop(random.randint(0, len(critical1) - 1)))
            random.shuffle(block)

            for stim1 in block:
                self.stimuli.append(stim1)
            print len(self.stimuli)

    def runexp(self):
        """ Runs the experiment """
        #self.instruction()
        # Run the main trial 1st part
        for stim in self.stimuli:
            # Play and record
            self.trial(stim)

        self.show_txt("Merci, on peut commencer l'experience.")
        time.sleep(1)
        mouse = self.getMouse()
        self.stim_file.close()
        self.quit()

    def sleep(self, timer):
        for i in range(0, timer):
            time.sleep(1)
            print '.', 
            continue


    def trial(self, stim, train = 0):
        """ Play and record a trial stimulus """
        # show the text
        self.beep.play()
        rt = time.time()
        self.show_txt(stim[1])
        self.show_txt(stim[2], 50)
        self.show_txt("[Prenez votre temps.]", 110)
        self.show_txt("[Quand vous etes pret, pressez la barre espace.]", 140)
        time.sleep(1)
        mouse = self.getMouse()
        rt = time.time() - rt
        self.beep.play()
        # Starts recording
        self.show_txt('           [Enregistrement en cours...]           ', 110)
        self.show_txt('           [Pressez la barre espace quand vous avez fini.]           ', 140)
        self.soundrec(os.path.join(self.stim_dir, stim[6]))
        mouse = self.getMouse()
        time.sleep(1)
        self.show_txt(stim[3])
        self.show_txt('(v)rai ou (f)aux?', 50)

        print stim
        stim_tosave = [stim[6], stim[1], stim[2]]
        self.saveStim(stim_tosave, self.getKey(), rt)
        time.sleep(0.1)

    def show_txt(self, exp_text, yspace=0):
        """ Print a string in the screen """
        # first rendering
        if not yspace:
            self.screen.fill(self.black)
        text = self.myfont.render(exp_text, True, self.white, self.black)
        textRect = text.get_rect()
        textRect.centerx = self.screen.get_rect().centerx
        textRect.centery = self.screen.get_rect().centery + yspace
        self.screen.blit(text, textRect)
        pygame.display.update()

    def soundrec(self, filename, train = 0):
        """ Record the response as a WAVE """
        p = pyaudio.PyAudio()
        stream = p.open(format = self.FORMAT,
                channels = self.CHANNELS,
                rate = self.RATE,
                input = True,
                output = True,
                frames_per_buffer = self.chunk)

        # 60 secs recording
        all = []
        done = False
        for i in range(0, self.RATE / self.chunk * self.RECORD_SECONDS):
            if done:
                break
            data = stream.read(self.chunk)
            all.append(data)
            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    if event.dict['key'] == pygame.K_ESCAPE:
                        self.quit()
                if event.type == pygame.KEYDOWN:
                    if event.dict['key'] == pygame.K_SPACE:
                        self.show_txt('                          Enregistrement termine.                          ', 110)
                        self.show_txt('                          Pressez la barre espace pour continuer.                          ', 140)
                        done = True
                        break
                if event.type == pygame.MOUSEBUTTONUP:
                    if event.dict['button'] == 1:
                        # Done recording
                        done = True
                        break

        # Done recording
        print 'Recording done: ' + filename
        stream.close()
        p.terminate()

        # write data to WAVE file
        if not train:
            data = ''.join(all)
            wf = wave.open(filename + ".wav", 'wb')
            wf.setnchannels(self.CHANNELS)
            wf.setsampwidth(p.get_sample_size(self.FORMAT))
            wf.setframerate(self.RATE)
            wf.writeframes(data)
            wf.close()

    def getMouse(self):
        """ Wait for mouse input """
        # Avoid unwanted double-clicks or key pressed
        time.sleep(0.5)
        pygame.event.clear()
        done = False
        while done == False:
            for event in pygame.event.get(): # User did something
                if event.type == pygame.KEYDOWN	:
                    if event.dict['key'] == pygame.K_ESCAPE:
                        self.quit()
                    elif event.dict['key'] == pygame.K_SPACE:
                        return 1
                if event.type == pygame.MOUSEBUTTONUP:
                    if event.dict['button'] == 1:
                        return 1
                    elif event.dict['button'] == 3:
                        return 2

    def getKey(self):
        time.sleep(0.2)
        pygame.event.clear()
        done = False
        while done == False:
            for event in pygame.event.get(): # User did something
                if event.type == pygame.KEYDOWN	:
                    if event.dict['key'] == pygame.K_ESCAPE:
                        self.quit()
                    elif event.dict['key'] in [pygame.K_v, pygame.K_f]:
                        return event.dict['key']

    def saveStim(self, stimlog, key, rt):
        if key == 118: key = "V"
        else: key = "F"
        content = stimlog[0] + "\t" + stimlog[1] + "\t" + stimlog[2] + "\t" + key + "\t" + str(rt)[0:5] + "\n"
        print content
        self.stim_file.writelines(content)

    def quit(self):
        self.stim_file.close()
        pygame.quit()
        sys.exit(1)

def main():
    # Initialise pygame's mixer
    pygame.mixer.init(frequency=22050, size=-16, channels=1, buffer=4096)
    if not pygame.mixer:
        print 'Pygame error, sound disabled'
        sys.exit(1)

    badinput = 0
    while True:
        info = {}
        info['sujet']  = raw_input('sujet: ')
        # info['sessione'] = raw_input('sessione: ')
        # Directory containg the two lists of stimuli for the subject
        stimuli_dir = os.path.join('stimuli', info['sujet'])
        if not info['sujet']: # or not info['sessione']:
            print 'Inserire il campo sujet'
            continue
        try:
            info['sujet'].decode('ascii')
        except:
            print "Usa solo caratteri ascii"
            continue
        # First session
        if os.path.exists(stimuli_dir):
            print "sujet esistente"
            # Ok, this shouldn't be so rude
            continue

        experimentNv = PsExperiment(info)
        break

    experimentNv.runexp()

if __name__ == '__main__':
    main()
