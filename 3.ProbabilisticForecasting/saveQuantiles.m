function saveQuantiles(filename, quantiles, type)
    if type == "Sun"
        quantilesSun = quantiles;
        save(filename, 'quantilesSun')
    else
        quantilesNon = quantiles;
        save(filename, 'quantilesNon')
    end
end