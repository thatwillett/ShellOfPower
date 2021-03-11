<#
.Synopsis
   Reading is good. Enter: Goodreads (bum bum bum)
.DESCRIPTION
   Probably the most amazing function we've ever seen. Super useful and something we'll remember for the rest of our lives. You can quickly use the Goodreads API to get user, author, books, or books by author.
.ENDPOINT
   Specific Endpoint to call with the Goodreads API.
   Choose between:
   [User]  [Author]  [BooksByAuthor]  [Book]
.CRITERIA
   This is the search string you're wanting to look up. Could be the author's name, title of book, etc.
.EXAMPLE
    Get information about author named HG Wells:
    
    API-Quickie -Endpoint Author -Criteria 'HG Wells'
.EXAMPLE
    Get information about an author and then pipe the author ID to get books by the author. Notice we can pipe to the Criteria parameter and the Endpoint is positioned at 0 so if it's our first parameter we don't have to define it with -Endpoint
    
    (API-Quickie author -Criteria 'Ernest Cline').author.id | API-Quickie booksbyauthor
#>
function API-Quickie{
    [CmdletBinding()]
    Param(
        # API Endpoint
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateSet('User','Author','BooksByAuthor','Book')]
        $Endpoint,

        # Criteria for the endpoint (usually the id of the object or name to query)
        [Parameter(ValueFromPipeline=$true)]
        $Criteria
    )
    Begin{
        $Key = '3ZjCCwF94iXQHUzceAdkA'
        $KeyString = "key=$Key"
        $BaseURL = 'https://www.goodreads.com/'
    }
    Process{
        Switch ($Endpoint){
            'User'{
                $EndpointString = "user/show/$Criteria.xml?$KeyString"
                $URI = $BaseURL + $EndpointString
                #https://www.goodreads.com/user/show/8898794.xml?key=3ZjCCwF94iXQHUzceAdkA
            }
            'Author'{
                #Search author by name
                $EndpointString = 'api/author_url/'
                $URI = $BaseURL + $EndpointString + $Criteria + "/?$KeyString"
                #https://www.goodreads.com/api/author_url/Orson%20Scott%20Card?key=3ZjCCwF94iXQHUzceAdkA
            }
            'BooksByAuthor'{
                #Books by Author using Author's ID
                $EndpointString = "author/list/$Criteria" + "?format=xml&$KeyString"
                $URI = $BaseURL + $EndpointString
                #https://www.goodreads.com/author/list/18541?format=xml&key=3ZjCCwF94iXQHUzceAdkA
            }
            'Book'{
                #Book Info using Book's ID
                $EndpointString = "book/show/$Criteria.xml?$KeyString"
                $URI = $BaseURL + $EndpointString
                #https://www.goodreads.com/book/show/50.xml?key=3ZjCCwF94iXQHUzceAdkA
            }
        }

        if($Endpoint -eq 'BooksByAuthor'){
            
            #Get Results
            $Results = (Invoke-RestMethod -Uri $URI -Method Get).GoodreadsResponse

            #This endpoint only returns 30 books at a time,
            #so the "end" is the last book returned in this call,
            #and "total" is the total number of books that Goodreads has for this author
            #if there is last book returned doesn't equal the total, we want to call it again
            if($Results.author.books.end -ne $Results.author.books.total){

                #Our first call is technically Page 1, even without the page parameter defined
                $PageNumber = 2
                $CombinedResults = @()
                $CombinedResults += $Results.author.books.book

                #Now, let's add the page parameter and call again, adding the $Results to the $CombinedResults array
                #and then increment the $PageNumber by 1. Do all of this until the last book returned
                #is the same number as the total number of books in Goodreads for this author
                Do{
                    $URI += "&page=$PageNumber"
                    $Results = (Invoke-RestMethod -Uri $URI -Method Get).GoodreadsResponse
                    $CombinedResults += $Results.author.books.book
                    $PageNumber ++
                }
                Until($Results.author.books.end -eq $Results.author.books.total)

            #Finall, return the combined results of all of the books
            $CombinedResults
            }
            #this else is used if the author has less than 30 books
            else{
                $Results.author.books.book
            }
        }
        #else (if the endpoint isn't 'BooksByAuthor')
        else{
            $Results = Invoke-RestMethod -Uri $URI -Method Get
            $Results.GoodreadsResponse
        }
    }
    End{
    }
}