library(twitteR)
library(mongolite)
library(streamR)
library(ROAuth)
library(jsonlite)
library(RMongo)

consumerKey = "5ciGLNgHqns9NgAhmTTGytNz2"
consumerSecret = "Z2p10WyS0aJM2yR13iPH6wM0KUpZNVkJJLMJ9DOPFSFOoXmTPS"
accessToken = "844242463632117763-s849G8xpdXzJoZWBmxO8ln1zIbtArUN"
accessSecret = "IexemekHDJkyRwGdpvXVqcM3Dys6UecG5aJe2u58KtrrE"

#may require field: requestURL=requestURL, accessURL
my_oauth <- OAuthFactory$new(consumerKey=consumerKey,
                             consumerSecret=consumerSecret, 
                             accessURL=accessURL, authURL=authURL)

setup_twitter_oauth(consumer_key = consumerKey, consumer_secret = consumerSecret,
                    access_token = accessToken, access_secret = accessSecret)
tweets <- filterStream( file.name="tweets.json",
              track="trump", timeout=300, tweets=100, oauth=my_oauth )
                                                                  ###mongolite###
c = mongo(collection = "MemeData", db = "Tweets", url = "mongodb://localhost")
tweets.df <- twListToDF(tweets)
tweetsJSON <- toJSON(tweets.df)
c$insert(fromJSON(tweets))

                                                                  ###visualization###
#sapply to return list into vector
tweets.text = sapply(tweets,function(t) t$getText())
#create vector corpus of tweets
tweetsCorp = Corpus(VectorSource(tweets.text))
termDocMx = TermDocumentMatrix(tweetsCorp,control = list(removePunctuation = TRUE, stopwords = c("Trump", "trump","https",stopwords("english")),removeNumbers = TRUE, tolower = FALSE))
mat = as.matrix(termDocMx)
tfreq = sort(rowSums(mat), decreasing = TRUE)
tfreqdf = data.frame(word = names(tfreq), freq=tfreq)
wordcloud(tfreqdf$word, tfreqdf$freq, random.order=FALSE, colors = brewer.pal(12, "Paired"))
