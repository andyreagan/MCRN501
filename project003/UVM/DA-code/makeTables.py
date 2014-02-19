#!/opt/local/bin/python
# 
# makeTables.py
#
# load the data from the parameter estimation experiment
# and print LaTeX tables, and make figures
#
# USAGE
# ./makeTables.py [figures,tables] [all,morgan,andy]
#
# note: option "tables" only works with "andy"

## always need this
from numpy import array

def squared(tmpFloat):
  value = tmpFloat**2
  return value



def loadDataDict(allResults,allResultErrors,obsErrorDict):
  from numpy import sqrt
  print 'loading data'
  
  for errorDist in ['normal','uniform']:
    allResults[errorDist] = dict()
    allResultErrors[errorDist] = dict()
    for rho in [22,28,35]:
      allResults[errorDist][rho] = dict()
      allResultErrors[errorDist][rho] = dict()
      for numObsVar in [1,3]:
        allResults[errorDist][rho][numObsVar] = dict()
        allResultErrors[errorDist][rho][numObsVar] = dict()
        for obsError in obsErrorDict[errorDist]:
          allResults[errorDist][rho][numObsVar][obsError] = dict()
          allResultErrors[errorDist][rho][numObsVar][obsError] = dict()
          for subSampleAlpha in [1,5,25,50]:
            allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha] = []
            allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha] = []
            for expCount in range(1,6):
              ## "data/${ERRORDIST}_${OBSERROR}_${NUMRUNS}_${RUNTIME}_${SUBSAMPLEALPHA}_${RHO}_${OBSVAR}_${EXPCOUNT}_forecastEnds.csv"
              datafName="data/{0}_{1:g}_{2}_{3}_{4}_{5}_{6}_{7}_forecastEnds.csv".format(errorDist,obsError,numRuns,runTime,subSampleAlpha,rho,numObsVar,expCount)
              ## try:
              f = open(datafName,'r')
  	      ## fileOpened = 1
              tmpResults = []
              for line in f:
                tmpResults.append(map(float,line.rstrip().split(',')))
              f.close()
              ## except:
  	      ## fileOpened = 0
  	      ## print 'could not open file {}'.format(datafName)
  	      ## if fileOpened:
              resultsResults = []
  	      ## print tmpResults
              for i in range(1,len(tmpResults[0])):
                resultsResults.append(sqrt(sum(map(squared,[tmpResults[j][0]-tmpResults[j][i]for j in range(len(tmpResults))]))))
              ## print resultsResults
              ## print min(resultsResults)
              minIndex = resultsResults.index(min(resultsResults))+1
              ## print minIndex
              allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha].append([tmpResults[i][minIndex] for i in range(3,6)])
              allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha].append(min(resultsResults))

## print the table
def writeTable(allResults,obsErrorDict):
  print 'printing table'
  g = open('allTables.tex','w')
  for errorDist in ['normal','uniform']:
    for rho in [22,28,35]:
      for numObsVar in [1,3]:
        for obsError in obsErrorDict[errorDist]:
          for subSampleAlpha in [1,5,25,50]:
            g.write('Parameters: $\\sigma=10, b=8/3, R={}$\\\\\n'.format(rho))
            g.write('noise Type: {} with magnitude {}, using every {} observation(s) of first {} variables.\\\\\n'.format(errorDist,obsError,subSampleAlpha,numObsVar))
            g.write('\\begin{tabular}{cccc}\n')
            g.write('\\hline Experiment ID & b & $\\sigma$ & R \\\\ \\hline \n')
            for expCount in range(5):
              g.write('{} & '.format(expCount))
              ## print allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
              g.write('{} & '.format(allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount][0]))
              g.write('{} & '.format(allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount][1]))
              g.write('{}\\\\ \\hline \n '.format(allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount][2]))
            g.write('\\end{tabular}\\\\\n')
  g.close()

def heatMap01(allResults,allResultErrors,obsErrorDict):
  # fix each of these to make a figure
  for errorDist in ['normal','uniform']:
    for numObsVar in [1,3]:
      for obsError in obsErrorDict[errorDist]:
        expCount = 0
        i = -1
        tmpMatrix = []
        # picname = '.png'.format(errorDist,rho,numObsVar,obsError,subSampleAlpha)
        picname = 'figures/{}_obsVar{}_obsError{}_unclipped.png'.format(errorDist,numObsVar,obsError)
        picnamepdf = 'figures/{}_obsVar{}_obsError{}_unclipped.pdf'.format(errorDist,numObsVar,obsError)
        # create a figure, fig is now a matplotlib.figure.Figure instance
        fig = plt.figure()
        ax1 = fig.add_axes([0.2,0.2,0.7,0.7]) #  [left, bottom, width, height]          
        # vary this parameter
        for rho in [22,28,35]:
          i += 1
          results = []
          # and vary this parameter
          for subSampleAlpha in [1,5,25,50]:
            ## print allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            ## print allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            # tmpMatrix[i].append(sum(allResults[errorDist][rho][numObsVar][obsErrorDict[errorDist][1]][subSampleAlpha][expCount]))
            result = allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            results.append(allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount])
          tmpMatrix.append(array(results))
  
        ## print errorDist,numObsVar,obsError
        ## print tmpMatrix
        ## tmpMatrix = np.clip(array(tmpMatrix),0,10)
        ## print tmpMatrix
        ## tmpMatrix = np.clip(array([[0,1,2,float('nan')] for i in range(3)]),0,10)
        ## print tmpMatrix
        maskedArray = np.ma.array(tmpMatrix,mask=np.isnan(tmpMatrix))
        cmap = cm.coolwarm
        cmap.set_bad(color = 'k', alpha = 1.)
        ## ax1.imshow(maskedArray, interpolation='nearest', cmap=cmap, edgecolors='k')
        tmpp = ax1.pcolormesh(maskedArray,cmap=plt.cm.coolwarm,edgecolors='k') #shading='faceted')
        cbar = plt.colorbar(tmpp)
        ## cbar.ax.set_yticklabels([str(min(tmpMatrix[0])),str(max(tmpMatrix[0]))])
  
        ax1.set_xlabel('Sub Sample Alpha')
        ax1.set_ylabel('Rho')
        # ax1.set_xlim([min(dates)-buffer,max(dates)+buffer]) 
        # ax1.set_ylim([0,24])
  
        ax1.set_title('Performance of DA on L63')
        plt.xticks([float(i)+0.5 for i in range(4)])
        plt.yticks([float(i)+0.5 for i in range(3)])
        ax1.set_xticklabels([1,5,25,50])
        ax1.set_yticklabels([22,28,35])
        plt.savefig(picname)
        plt.savefig(picnamepdf)
        plt.close(fig)

def heatMap02(allResults,allResultErrors,obsErrorDict):
  # fix these
  for errorDist in ['normal','uniform']:
    for numObsVar in [1,3]:
      ## for obsError in obsErrorDict[errorDist]:
      for rho in [22,28,35]:
        expCount = 0
        i = -1
        tmpMatrix = []
        picname = 'figures/{}_obsVar{}_rho{}_unclipped.png'.format(errorDist,numObsVar,rho)
        picnamepdf = 'figures/{}_obsVar{}_rho{}_unclipped.pdf'.format(errorDist,numObsVar,rho)
        ## create a figure, fig is now a matplotlib.figure.Figure instance
        fig = plt.figure()
        ax1 = fig.add_axes([0.2,0.2,0.7,0.7]) #  [left, bottom, width, height]          
        ## vary this parameter
        for obsError in obsErrorDict[errorDist]:
          i += 1
          results = []
          ## and vary this parameter
          for subSampleAlpha in [1,5,25,50]:
            ## print allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            ## print allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            ## tmpMatrix[i].append(sum(allResults[errorDist][rho][numObsVar][obsErrorDict[errorDist][1]][subSampleAlpha][expCount]))
            result = allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            results.append(allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount])
          tmpMatrix.append(array(results))
  
        ## print errorDist,numObsVar,obsError
        ## print tmpMatrix
        ## tmpMatrix = np.clip(array(tmpMatrix),0,10)
        ## print tmpMatrix
        ## tmpMatrix = np.clip(array([[0,1,2,float('nan')] for i in range(3)]),0,10)
        ## print tmpMatrix
        maskedArray = np.ma.array(tmpMatrix,mask=np.isnan(tmpMatrix))
        cmap = cm.coolwarm
        cmap.set_bad(color = 'k', alpha = 1.)
        ## ax1.imshow(maskedArray, interpolation='nearest', cmap=cmap, edgecolors='k')
        tmpp = ax1.pcolormesh(maskedArray,cmap=plt.cm.coolwarm,edgecolors='k') #shading='faceted')
        cbar = plt.colorbar(tmpp)
        ## cbar.ax.set_yticklabels([str(min(tmpMatrix[0])),str(max(tmpMatrix[0]))])
        
        ax1.set_xlabel('Sub Sample Alpha')
        ax1.set_ylabel('Observational Error')
        ax1.set_title('Rho = {}'.format(rho))
        # ax1.set_xlim([min(dates)-buffer,max(dates)+buffer]) 
        # ax1.set_ylim([0,24])
  
        plt.xticks([float(i)+0.5 for i in range(4)])
        plt.yticks([float(i)+0.5 for i in range(len(obsErrorDict[errorDist]))])
        ax1.set_xticklabels([1,5,25,50])
        ax1.set_yticklabels(obsErrorDict[errorDist])
        plt.savefig(picname)
        plt.savefig(picnamepdf)
  
        plt.close(fig)

def heatMap03(allResults,allResultErrors,obsErrorDict):
  # fix these
  for errorDist in ['normal','uniform']:
    for numObsVar in [1,3]:
      for rho in [22,28,35]:
        expCount = 0
        i = -1
        tmpMatrix = []
        # picname = '.png'.format(errorDist,rho,numObsVar,obsError,subSampleAlpha)
        picname = 'figures/{}_obsVar{}_rho{}_unclipped.png'.format(errorDist,numObsVar,rho)
        picnamepdf = 'figures/{}_obsVar{}_rho{}_unclipped.pdf'.format(errorDist,numObsVar,rho)
        # create a figure, fig is now a matplotlib.figure.Figure instance
        fig = plt.figure()
        ax1 = fig.add_axes([0.2,0.2,0.7,0.7]) #  [left, bottom, width, height]          
        # vary this parameter
        for obsError in obsErrorDict[errorDist]:
          i += 1
          results = []
          # and vary this parameter
          for subSampleAlpha in [1,5,25,50]:
            # print allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            # print allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            # tmpMatrix[i].append(sum(allResults[errorDist][rho][numObsVar][obsErrorDict[errorDist][1]][subSampleAlpha][expCount]))
            result = allResults[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount]
            results.append(allResultErrors[errorDist][rho][numObsVar][obsError][subSampleAlpha][expCount])
          tmpMatrix.append(array(results))
  
        # print errorDist,numObsVar,obsError
        # print tmpMatrix
        ## tmpMatrix = np.clip(array(tmpMatrix),0,10)
        ## print tmpMatrix
        ## tmpMatrix = np.clip(array([[0,1,2,float('nan')] for i in range(3)]),0,10)
        ## print tmpMatrix
        maskedArray = np.ma.array(tmpMatrix,mask=np.isnan(tmpMatrix))
        cmap = cm.coolwarm
        cmap.set_bad(color = 'k', alpha = 1.)
        ## ax1.imshow(maskedArray, interpolation='nearest', cmap=cmap, edgecolors='k')
        tmpp = ax1.pcolormesh(maskedArray,cmap=plt.cm.coolwarm,edgecolors='k') #shading='faceted')
        cbar = plt.colorbar(tmpp)
        ## cbar.ax.set_yticklabels([str(min(tmpMatrix[0])),str(max(tmpMatrix[0]))])
        
        ax1.set_xlabel('Sub Sample Alpha')
        ax1.set_ylabel('Observational Error')
        ax1.set_title('Rho = {}'.format(rho))
        # ax1.set_xlim([min(dates)-buffer,max(dates)+buffer]) 
        # ax1.set_ylim([0,24])
  
        plt.xticks([float(i)+0.5 for i in range(4)])
        plt.yticks([float(i)+0.5 for i in range(len(obsErrorDict[errorDist]))])
        ax1.set_xticklabels([1,5,25,50])
        ax1.set_yticklabels(obsErrorDict[errorDist])
        plt.savefig(picname)
        plt.savefig(picnamepdf)
  
        plt.close(fig)

def heatMap04(allResults,allResultErrors,obsErrorDict):
  ## fix these
  for errorDist in ['normal','uniform']:
    for I in [4,8,10,15]:
      ## for obsError in obsErrorDict[errorDist]:
      ## for rho in [22,28,35]:
      expCount = 0
      i = -1
      tmpMatrix = []
      ## picname = '.png'.format()
      picname = 'figures/L96_{}_I{}_J4_h1_b10_c10_F14.png'.format(errorDist,I)
      picnamepdf = 'figures/L96_{}_I{}_J4_h1_b10_c10_F14.pdf'.format(errorDist,I)
  
      ## create a figure, fig is now a matplotlib.figure.Figure instance
      fig = plt.figure()
      ax1 = fig.add_axes([0.2,0.2,0.7,0.7]) #  [left, bottom, width, height]          
      ## vary this parameter
      for obsError in obsErrorDict[errorDist]:
        i += 1
        results = []
        if i == 0:
          results = [float('nan') for x in range(4)]
        else:
          ## and vary this parameter
          for subSampleAlpha in [1,5,25,50]:
            results.append(np.random.randint(100))
        tmpMatrix.append(array(results))
  
        print errorDist,obsError
        print tmpMatrix

      tmpMatrix = np.clip(array(tmpMatrix),0,40)
      ## print tmpMatrix
      ## tmpMatrix = np.clip(array([[0,1,2,float('nan')] for i in range(3)]),0,10)
      ## print tmpMatrix
      maskedArray = np.ma.array(tmpMatrix,mask=np.isnan(tmpMatrix))
      cmap = cm.coolwarm
      cmap.set_bad(color = 'k', alpha = 1.)
      ## ax1.imshow(maskedArray, interpolation='nearest', cmap=cmap, edgecolors='k')
      tmpp = ax1.pcolormesh(maskedArray,cmap=plt.cm.coolwarm,edgecolors='k') #shading='faceted')
      cbar = plt.colorbar(tmpp)
      ## cbar.ax.set_yticklabels([str(min(tmpMatrix[0])),str(max(tmpMatrix[0]))])
      
      ax1.set_xlabel('Sub Sample Alpha')
      ax1.set_ylabel('Observational Error')
      ax1.set_title('I = {}'.format(I))
      # ax1.set_xlim([min(dates)-buffer,max(dates)+buffer]) 
      # ax1.set_ylim([0,24])
      
      plt.xticks([float(i)+0.5 for i in range(4)])
      plt.yticks([float(i)+0.5 for i in range(len(obsErrorDict[errorDist]))])
      ax1.set_xticklabels([1,5,25,50])
      ax1.set_yticklabels(obsErrorDict[errorDist])
      plt.savefig(picname)
      plt.savefig(picnamepdf)
  
      plt.close(fig)




if __name__ == "__main__":

  ## tunable parameters
  ## fixed for now
  numRuns=100
  runTime=200

  ## save weird experiment parameters
  obsErrorDict = dict()
  obsErrorDict['normal']=[0,0.01,0.05,0.1,0.25,0.5,1,2]
  obsErrorDict['uniform']=[0,0.5,2,4,6,8,10]

  ## initialize storage
  allResults = dict()
  allResultErrors = dict()

  loadDataDict(allResults,allResultErrors,obsErrorDict)

  from sys import argv

  if argv[1] == 'tables':
    writeTable(allResults,obsErrorDict)

  if argv[1] == 'figures':
    print "making figure"
    
    import matplotlib.pyplot as plt
    from matplotlib import cm
    import numpy as np
    ## test the data storage
    print allResults['uniform'][22][3][0.5][5][0]
    print allResultErrors['uniform'][22][3][0.5][5][0]

    heatMap01(allResults,allResultErrors,obsErrorDict)
    heatMap02(allResults,allResultErrors,obsErrorDict)
    heatMap03(allResults,allResultErrors,obsErrorDict)
    heatMap04(allResults,allResultErrors,obsErrorDict)
