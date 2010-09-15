classdef prtRvMultinomial < prtRv
    properties
        probabilities
    end
    
    properties (Dependent = true)
        nCategories
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (Hidden = true)
        approximatelyEqualThreshold = 1e-4;
    end
    
    methods
        % The Constructor
        function R = prtRvMultinomial(varargin)
            R.name = 'Multinomial Random Variable';
            
            R = constructorInputParse(R,varargin{:});
        end
        
        function R = mle(R,X)
            N_bar = sum(X,1);
            R.probabilities = N_bar./sum(N_bar(:));
        end
        
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            assert(size(X,2) == R.nCategories,'Incorrect dimensionality for RV object.')
            
            vals = sum(bsxfun(@times,X,R.probabilities),2);
        end
        
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated because this RV object is not yet valid.')
            
            vals = log(pdf(R,X));
        end
        
        function vals = draw(R,N)
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            
            vals = zeros(N,R.nCategories);
            vals(sub2ind([N, R.nCategories], (1:N)',drawIntegers(R,N))) = 1;
        end
        
        function vals = drawIntegers(R,N)
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
            histBinEdges = min([0 cumsum(R.probabilities)],1);
            [~, vals] = histc(rand(N,1),histBinEdges);
            
        end
        
        function varargout = plotPdf(R,varargin)
            h = bar(1:R.nCategories,R.probabilities,'k');
            
            ylim([0 1])
            xlim(R.plotLimits());
            
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        
        function varargout = plotCdf(R,varargin)
            h = bar(1:R.nCategories,cumsum(R.probabilities),'k');
            
            ylim([0 1])
            xlim(R.plotLimits());
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
        
    end
    
    % Set methods
    methods
        function R = set.probabilities(R,probs)
            assert(abs(sum(probs)-1) < R.approximatelyEqualThreshold,'Probability vector must must sum to 1.')
            R.probabilities = probs;
        end
    end
    
    % Get methods
    methods
        function val = get.nCategories(R)
            if ~isempty(R.probabilities)
                val = length(R.probabilities);
            else
                val = [];
            end
        end
    end
    
    methods (Hidden = true)
        function val = isValid(R)
            val = ~isempty(R.probabilities);
        end
        function val = plotLimits(R)
            if R.isValid
                val = [0.5 0.5+R.nCategories];
            else
                error('multinomial:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end         
        
        
        function val = isPlottable(R) %#ok
            val = true; % Always plottable
        end
        
        function R = weightedMle(R,X,weights)
            assert(numel(weights)==size(X,1),'The number of weights must mach the number of observations.');
            
            weights = weights(:);
            
            N_bar = sum(bsxfun(@times,X,weights),1);
            
            R.probabilities = N_bar./sum(N_bar(:));
        end
    end
end