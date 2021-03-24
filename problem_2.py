# Problem 2: Assuming we have a huge file (500G) that contains all of the contents 
# from millions of blogs. Write some codes to count how many “a” and “the” are used 
# in such a huge file. You can use either pseudo code or PHP/Python/Shell Script.
# Make sure it would run well when a huge file is provided as the 
# input from the terminal (command line).


#Solution:
    # Since the file size is 500 GB. This file cannot be openned and worked on a single machine.
    # Since each typical App servers RAM size is around 64 GB, I can only cater to a maximum file size of upto around 40 GB.
    # We need to make use of multiple machine to do the job, thus here Big Data techniques could be used such as Spark, Pig , Hive
    # I am using Spark for this purpose along with Python.
    # I have created a dummy file with file size around 250 MB name scrapped data containing wikipedia page data.
    # Then created a SparkSession which in turn would create a SparkContext.
    # While creating SparkSession mentioned local as the cluster to make use of all the core available in the local machine.
    # Clean all the data and make it in lower case.
    # splited the data word wise and picked the words containing either 'a' or 'the' in it.
    # Mapped each word with 1 and reduced by summing same word resulting the word count for each word.
    # Displayed the data 


from pyspark.sql import SparkSession
from pyspark.conf import SparkConf

def lower_clean_str(x):
    '''
    A function to first all the text in lower case and then clean from punctuation letters
    '''
    punc='!"#$%&\'()*+,./:;<=>?@[\\]^_`{|}~-'
    lowercased_str = x.lower()
    for ch in punc:
        lowercased_str = lowercased_str.replace(ch, '')
    return lowercased_str


spark=SparkSession.builder\
    .master("local[*]")\
    .appName("WordCount")\
    .getOrCreate()

sc=spark.sparkContext
sc.setLogLevel('WARN')

scrapped_data='C:/Users/arpit/Desktop/glu_mobile_solution/scrapped_data.txt'
rdd_data=sc.textFile(scrapped_data)


rdd_data = rdd_data.map(lower_clean_str)
rdd_data = rdd_data.flatMap(lambda line: line.split(" "))
rdd_data = rdd_data.filter(lambda word:word!='')
rdd_data = rdd_data.filter(lambda word:word in ['a','the'])

rdd_count = rdd_data.map(lambda  word:(word,1))

rdd_count_rbk = rdd_count.reduceByKey(lambda x,y:(x+y)).sortByKey()
rdd_count_rbk = rdd_count_rbk.map(lambda x:(x[1],x[0]))
final_data=rdd_count_rbk.sortByKey(False).take(2)
print(final_data)


