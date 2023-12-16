#!/bin/bash
# Originally developed by corsaro and dakk, updated by HelpingHand to support Liskv4

if ! command -v jq &> /dev/null
then
    echo "jq not present"
    exit
fi
if ! command -v curl &> /dev/null
then
    echo "curl not present"
    exit
fi
if ! command -v lisk-core &> /dev/null
then
    echo "lisk-core not present or not in the PATH"
    exit
fi

apiToken="" # your telegram api token
chat_id="" # your telegram ID

olda=$(lisk-core generator status)

while true; do
        a=$(lisk-core generator status)
        aheightforged=`echo $a | jq -r '.. | .maxHeightGenerated? //empty'`
        oldaaheightforged=`echo $olda | jq -r '.. | .maxHeightGenerated? //empty'`

        echo "Previously generated: $aheightforged; New value: $oldaaheightforged"

        if [[ "$aheightforged" -gt "$oldaaheightforged" ]]
        then
            address=$(echo $a | jq -r '.. | .address? //empty')
            height=$(echo $a | jq -r '.. | .height? //empty')
            maxHeightGenerated=$aheightforged
            maxHeightPrevoted=$(echo $a | jq -r '.. | .maxHeightPrevoted? //empty')
            # $address $height $maxHeightGenerated $maxHeightPrevoted
            echo "Generated Block $address - $height - $maxHeightGenerated" 
            curl -s -X POST https://api.telegram.org/bot$apiToken/sendMessage -d text="Lisk generated a block - address:'$address' height:'$height' maxHeightGenerated:'$maxHeightGenerated' maxHeightPrevoted: '$maxHeightPrevoted'" -d chat_id=$chat_id
                lisk-core generator export --output "$HOME/lisk-generated.json"
            tar -cvzf lisk-generated.tar.gz lisk-generated.json
            curl -F document=@"$HOME/lisk-generated.tar.gz" https://api.telegram.org/bot$apiToken/sendDocument?chat_id=$chat_id
        fi

        olda=$a

        sleep 10
done
